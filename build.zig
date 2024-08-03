const std = @import("std");
const builtin = @import("builtin");
const sokol = @import("sokol");
const examples = @import("examples.zig");
const Deps = @import("deps.zig").Deps;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var deps = Deps.init(b, target, optimize);
    inline for (examples.learnopengl_examples ++ examples.sokol_examples) |example| {
        const compile = if (target.result.isWasm()) wasm: {
            const lib = b.addStaticLibrary(.{
                .target = target,
                .optimize = optimize,
                .name = example.name,
                .root_source_file = b.path(example.root_source),
            });
            b.installArtifact(lib);
            // const install = b.addInstallArtifact(lib, .{});
            deps.inject_dependencies(lib);
            // deps.inject_ozz_animation(b, lib);

            const dep_emsdk = deps.dep_sokol.builder.dependency("emsdk", .{});

            // create a build step which invokes the Emscripten linker
            _ = try sokol.emLinkStep(b, .{
                .lib_main = lib,
                .target = target,
                .optimize = optimize,
                .emsdk = dep_emsdk,
                .use_webgl2 = true,
                .use_emmalloc = true,
                .use_filesystem = false,
                .shell_file_path = deps.dep_sokol.path("src/sokol/web/shell.html").getPath(b),
                .extra_args = &.{
                    // "-sERROR_ON_UNDEFINED_SYMBOLS=0",
                    "-sSTB_IMAGE=1",
                    "-g",
                    "-sTOTAL_MEMORY=200MB",
                    "-sUSE_OFFSET_CONVERTER=1",
                },
            });

            // need to inject the Emscripten system header include path into
            // the cimgui C library otherwise the C/C++ code won't find
            // C stdlib headers
            const emsdk_incl_path = dep_emsdk.path("upstream/emscripten/cache/sysroot/include");
            deps.dep_cimgui.artifact("cimgui_clib").addSystemIncludePath(emsdk_incl_path);

            // all C libraries need to depend on the sokol library, when building for
            // WASM this makes sure that the Emscripten SDK has been setup before
            // C compilation is attempted (since the sokol C library depends on the
            // Emscripten SDK setup step)
            deps.dep_cimgui.artifact("cimgui_clib").step.dependOn(&deps.dep_sokol.artifact("sokol_clib").step);

            // ...and a special run step to start the web build output via 'emrun'
            const run = sokol.emRunStep(b, .{
                .name = "run-" ++ example.name,
                .emsdk = dep_emsdk,
            });
            run.step.dependOn(&lib.step);
            b.step("run-" ++ example.name, "Run " ++ example.name).dependOn(&run.step);
            break :wasm lib;
        } else native: {
            const exe = b.addExecutable(.{
                .target = target,
                .optimize = optimize,
                .name = example.name,
                .root_source_file = b.path(example.root_source),
            });
            exe.addCSourceFile(.{ .file = b.path("c/stb_image.c") });
            deps.inject_dependencies(exe);
            deps.inject_ozz_animation(b, exe);
            b.installArtifact(exe);

            // ...and a special run step to start the web build output via 'emrun'
            const run = b.addRunArtifact(exe);
            b.step("run-" ++ example.name, "Run " ++ example.name).dependOn(&run.step);

            break :native exe;
        };

        if (example.shader) |shader| {
            // generate shader
            compile.step.dependOn(sokolShdc(
                b,
                target,
                shader,
            ));
        }
    }
}

// a separate step to compile shaders
pub fn sokolShdc(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    comptime shader: []const u8,
) *std.Build.Step {
    const optional_shdc = comptime switch (builtin.os.tag) {
        .windows => "win32/sokol-shdc.exe",
        .linux => "linux/sokol-shdc",
        .macos => if (builtin.cpu.arch.isX86()) "osx/sokol-shdc" else "osx_arm64/sokol-shdc",
        else => @panic("unsupported host platform, skipping shader compiler step"),
    };
    const tools = b.dependency("sokol-tools-bin", .{});
    const shdc_path = tools.path(b.pathJoin(&.{ "bin", optional_shdc })).getPath(b);
    const glsl = if (target.result.isDarwin()) "glsl410" else "glsl430";
    const slang = glsl ++ ":metal_macos:hlsl5:glsl300es:wgsl";
    return &b.addSystemCommand(&.{
        shdc_path,
        "-i",
        shader,
        "-o",
        shader ++ ".zig",
        "-l",
        slang,
        "-f",
        "sokol_zig",
    }).step;
}
