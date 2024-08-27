const std = @import("std");
const builtin = @import("builtin");
const emzig = @import("emsdk-zig");
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
    "-sASSERTIONS",
};
const WASM_ARGS_DYNAMIC = [_][]const u8{
    "-sMAIN_MODULE=1",
    "zig-out/web/sidemodule.wasm",
    "-sERROR_ON_UNDEFINED_SYMBOLS=0",
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const deps = Deps.init(b, target, optimize);

    if (target.result.isWasm()) {
        const dep_emsdk = b.dependency("emsdk-zig", .{}).builder.dependency("emsdk", .{});

        const side_wasm = try sidemodule.mesonWasm(b, optimize, dep_emsdk);
        buildWasm(b, target, optimize, &deps, &examples.all_examples, dep_emsdk, side_wasm);
    } else {
        const side_dll = sidemodule.mesonNative(b);
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
    // all C libraries need to depend on the sokol library, when building for
    // WASM this makes sure that the Emscripten SDK has been setup before
    // C compilation is attempted (since the sokol C library depends on the
    // Emscripten SDK setup step)
    // need to inject the Emscripten system header include path into
    // the cimgui C library otherwise the C/C++ code won't find
    // C stdlib headers
    const emsdk_incl_path = dep_emsdk.path(
        "upstream/emscripten/cache/sysroot/include",
    );
    // const emsdk_cpp_incl_path = dep_emsdk.path(
    //     "upstream/emscripten/cache/sysroot/include/c++/v1",
    // );

    const cimgui_clib_artifact = deps.dep_cimgui.artifact("cimgui_clib");
    cimgui_clib_artifact.addSystemIncludePath(emsdk_incl_path);
    cimgui_clib_artifact.step.dependOn(&deps.dep_sokol.artifact("sokol_clib").step);

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

        deps.inject_dependencies(lib);

        // create a build step which invokes the Emscripten linker
        const install = try emzig.emLinkStep(b, dep_emsdk, .{
            .lib_main = lib,
            .target = target,
            .optimize = optimize,
            .use_webgl2 = true,
            .use_emmalloc = true,
            .use_filesystem = true,
            .shell_file_path = deps.dep_sokol.path("src/sokol/web/shell.html").getPath(b),
            .release_use_closure = false,
            .extra_before = if (optimize == .Debug)
                &(WASM_ARGS ++ WASM_ARGS_DEBUG)
            else
                &WASM_ARGS,
            .extra_after = if (example.sidemodule)
                &WASM_ARGS_DYNAMIC
            else
                &.{},
        });
        b.getInstallStep().dependOn(&install.step);

        inline for (example.assets) |asset| {
            const install_asset = b.addInstallFileWithDir(b.path(asset.from), .prefix, "web/" ++ asset.to);
            install.step.dependOn(&install_asset.step);
        }

        // ...and a special run step to start the web build output via 'emrun'
        const run = emzig.emRunStep(b, dep_emsdk, .{ .name = example.name });
        run.step.dependOn(&install.step);
        b.step("run-" ++ example.name, "EmRun " ++ example.name).dependOn(&run.step);
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
        for (example.c_includes) |include| {
            exe.addIncludePath(b.path(include));
        }

        const install = b.addInstallArtifact(exe, .{});
        b.getInstallStep().dependOn(&install.step);
        inline for (example.assets) |asset| {
            const install_asset = b.addInstallFileWithDir(b.path(asset.from), .prefix, "bin/" ++ asset.to);
            install.step.dependOn(&install_asset.step);
        }

        const run = b.addRunArtifact(exe);
        run.setCwd(b.path("zig-out/bin"));
        run.step.dependOn(&install.step);
        b.step("run-" ++ example.name, "Run " ++ example.name).dependOn(&run.step);
        if (example.sidemodule) {
            if (target.result.os.tag == .windows) {
                exe.addLibraryPath(b.path("zig-out/lib"));
                // run.addPathDir("zig-out/bin");
            } else {
                // ubuntu
                exe.addLibraryPath(b.path("zig-out/lib/x86_64-linux-gnu"));
                // arch
                exe.addLibraryPath(b.path("zig-out/lib"));
            }
            exe.linkLibCpp();
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
