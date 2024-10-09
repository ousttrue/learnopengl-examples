const std = @import("std");
const emzig = @import("emsdk-zig");
const Deps = @import("Deps.zig");

const WASM_ARGS = [_][]const u8{
    // default 64MB
    "-sSTACK_SIZE=256MB",
    // must STACK_SIZE < TOTAL_MEMORY
    "-sTOTAL_MEMORY=1024MB",
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
    "zig-out/web/ozz-animation.wasm",
    "-sERROR_ON_UNDEFINED_SYMBOLS=0",
};

pub fn emLink(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    lib: *std.Build.Step.Compile,
    deps: *const Deps,
) std.Build.LazyPath {
    const emsdk_incl_path = deps.emsdk_dep.path(
        "upstream/emscripten/cache/sysroot/include",
    );

    lib.addSystemIncludePath(emsdk_incl_path);

    // create a build step which invokes the Emscripten linker
    const emcc = try emzig.emLinkCommand(b, deps.emsdk_dep, .{
        .lib_main = lib,
        .target = target,
        .optimize = optimize,
        .use_webgl2 = true,
        .use_emmalloc = true,
        .use_filesystem = true,
        .shell_file_path = deps.sokol_dep.path("src/sokol/web/shell.html").getPath(b),
        .release_use_closure = false,
        .extra_before = if (optimize == .Debug)
            &(WASM_ARGS ++ WASM_ARGS_DEBUG)
        else
            &WASM_ARGS,
    });

    emcc.addArg("-o");
    const out_file = emcc.addOutputFileArg(b.fmt("{s}.html", .{lib.name}));
    return out_file;
}
