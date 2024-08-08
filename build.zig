const std = @import("std");
const builtin = @import("builtin");
const sokol = @import("sokol");
const examples = @import("examples.zig");
const Deps = @import("deps.zig").Deps;
const sidemodule = @import("sidemodule.zig");

const WASM_ARGS = [_][]const u8{
    "-sTOTAL_MEMORY=200MB",
    "-sUSE_OFFSET_CONVERTER=1",
    "-sSTB_IMAGE=1",
    "-Wno-limited-postlink-optimizations",
};
const WASM_ARGS_DEBUG = [_][]const u8{
    "-g",
};
const WASM_ARGS_DYNAMIC = [_][]const u8{
    // "-sMAIN_MODULE=1",
    // "zig-out/bin/sidemodule.wasm",
    // "-sERROR_ON_UNDEFINED_SYMBOLS=0",
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const deps = Deps.init(b, target, optimize);

    if (target.result.isWasm()) {
        const dep_emsdk = deps.dep_sokol.builder.dependency("emsdk", .{});
        const side_wasm = try sidemodule.buildWasm(b, dep_emsdk);
        buildWasm(b, target, optimize, &deps, &examples.all_examples, dep_emsdk, side_wasm);
    } else {
        const side_dll = sidemodule.buildNative(b);
        buildNative(b, target, optimize, &deps, &examples.all_examples, side_dll);
    }
}

fn buildWasm(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    deps: *const Deps,
    comptime all_examples: []const examples.Example,
    dep_emsdk: *std.Build.Dependency,
    side_wasm: *std.Build.Step,
) void {
    // need to inject the Emscripten system header include path into
    // the cimgui C library otherwise the C/C++ code won't find
    // C stdlib headers
    const emsdk_incl_path = dep_emsdk.path(
        "upstream/emscripten/cache/sysroot/include",
    );
    const emsdk_cpp_incl_path = dep_emsdk.path(
        "upstream/emscripten/cache/sysroot/include/c++/v1",
    );

    inline for (all_examples) |example| {
        const lib = b.addStaticLibrary(.{
            .target = target,
            .optimize = optimize,
            .name = example.name,
            .root_source_file = b.path(example.root_source),
            .pic = true,
        });
        if (example.shader) |shader| {
            // glsl to glsl.zig
            lib.step.dependOn(sokolShdc(
                b,
                target,
                shader,
            ));
        }
        if (example.sidemodule) {
            lib.step.dependOn(side_wasm);
            // emcc main.c -s MAIN_MODULE=1 -o main.html -s "RUNTIME_LINKED_LIBS=['sidemodule.wasm']"
        }
        inline for (example.assets) |asset| {
            b.installFile(asset, "web/" ++ asset);
        }

        deps.inject_dependencies(lib);

        // deps.inject_ozz_animation(b, lib);
        if (example.c_srcs) |srcs| {
            lib.addCSourceFiles(.{
                .files = srcs,
                .flags = &.{
                    "-nostdinc",
                    "-nostdinc++",
                },
            });
            // this order is important
            lib.addSystemIncludePath(emsdk_incl_path);
            lib.addSystemIncludePath(emsdk_cpp_incl_path);
        }

        // create a build step which invokes the Emscripten linker
        const install = try sokol.emLinkStep(b, .{
            .lib_main = lib,
            .target = target,
            .optimize = optimize,
            .emsdk = dep_emsdk,
            .use_webgl2 = true,
            .use_emmalloc = true,
            .use_filesystem = false,
            .shell_file_path = deps.dep_sokol.path("src/sokol/web/shell.html").getPath(b),
            .extra_args = if (optimize == .Debug)
                if (example.sidemodule)
                    &(WASM_ARGS ++ WASM_ARGS_DEBUG ++ WASM_ARGS_DYNAMIC)
                else
                    &(WASM_ARGS ++ WASM_ARGS_DEBUG)
            else if (example.sidemodule)
                &(WASM_ARGS ++ WASM_ARGS_DYNAMIC)
            else
                &WASM_ARGS,
            .extra_args2 = if (example.sidemodule)
                &.{"zig-out/lib/libsidemodule.a"}
            else
                &.{},
        });

        deps.dep_cimgui.artifact("cimgui_clib").addSystemIncludePath(emsdk_incl_path);

        // all C libraries need to depend on the sokol library, when building for
        // WASM this makes sure that the Emscripten SDK has been setup before
        // C compilation is attempted (since the sokol C library depends on the
        // Emscripten SDK setup step)
        deps.dep_cimgui.artifact("cimgui_clib").step.dependOn(&deps.dep_sokol.artifact("sokol_clib").step);

        // ...and a special run step to start the web build output via 'emrun'
        const run = sokol.emRunStep(b, .{
            .name = example.name,
            .emsdk = dep_emsdk,
        });
        run.step.dependOn(&install.step);
        b.step("run-" ++ example.name, "Run " ++ example.name).dependOn(&run.step);
    }
}

fn buildNative(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    deps: *const Deps,
    comptime all_examples: []const examples.Example,
    side_dll: *std.Build.Step,
) void {
    inline for (all_examples) |example| {
        const exe = b.addExecutable(.{
            .target = target,
            .optimize = optimize,
            .name = example.name,
            .root_source_file = b.path(example.root_source),
        });
        if (example.shader) |shader| {
            // glsl to glsl.zig
            exe.step.dependOn(sokolShdc(
                b,
                target,
                shader,
            ));
        }
        if (example.sidemodule) {
            exe.step.dependOn(side_dll);
        }

        exe.addCSourceFile(.{ .file = b.path("c/stb_image.c") });
        deps.inject_dependencies(exe);
        if (example.c_srcs) |srcs| {
            exe.addCSourceFiles(.{
                .files = srcs,
            });
        }

        b.installArtifact(exe);

        // ...and a special run step to start the web build output via 'emrun'
        const run = b.addRunArtifact(exe);
        b.step("run-" ++ example.name, "Run " ++ example.name).dependOn(&run.step);
        if (example.sidemodule) {
            if (target.result.os.tag == .windows) {
                exe.addLibraryPath(b.path("zig-out/lib"));
                run.addPathDir("zig-out/bin");
            } else {
                exe.addLibraryPath(b.path("zig-out/lib/x86_64-linux-gnu"));
            }
            exe.linkSystemLibrary("sidemodule");
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
