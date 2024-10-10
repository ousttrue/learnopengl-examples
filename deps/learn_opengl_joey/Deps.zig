const std = @import("std");
const builtin = @import("builtin");

pub const Deps = @This();
sokol_dep: *std.Build.Dependency,
cimgui_dep: *std.Build.Dependency,
rowmath: *std.Build.Module,
emsdk_dep: *std.Build.Dependency,
stbi_dep: *std.Build.Dependency,

pub fn init(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) @This() {
    var deps = .{
        .rowmath = b.dependency("rowmath", .{}).module("rowmath"),
        .sokol_dep = b.dependency("sokol", .{
            .target = target,
            .optimize = optimize,
            .with_sokol_imgui = true,
        }),
        .cimgui_dep = b.dependency("cimgui", .{
            .target = target,
            .optimize = optimize,
        }),
        .emsdk_dep = b.dependency("emsdk-zig", .{}).builder.dependency("emsdk", .{}),
        .stbi_dep = b.dependency("stb_image", .{
            .target = target,
            .optimize = optimize,
        }),
    };

    // inject the cimgui header search path into the sokol C library compile step
    const cimgui_root = deps.cimgui_dep.namedWriteFiles("cimgui").getDirectory();
    deps.sokol_dep.artifact("sokol_clib").addIncludePath(cimgui_root);

    const cimgui_clib_artifact = deps.cimgui_dep.artifact("cimgui_clib");
    cimgui_clib_artifact.step.dependOn(&deps.sokol_dep.artifact("sokol_clib").step);
    if (target.result.isWasm()) {
        // all C libraries need to depend on the sokol library, when building for
        // WASM this makes sure that the Emscripten SDK has been setup before
        // C compilation is attempted (since the sokol C library depends on the
        // Emscripten SDK setup step)
        // need to inject the Emscripten system header include path into
        // the cimgui C library otherwise the C/C++ code won't find
        // C stdlib headers
        const emsdk_incl_path = deps.emsdk_dep.path(
            "upstream/emscripten/cache/sysroot/include",
        );
        cimgui_clib_artifact.addSystemIncludePath(emsdk_incl_path);
    }

    return deps;
}

pub fn inject_dependencies(
    self: @This(),
    _: *std.Build,
    compile: *std.Build.Step.Compile,
) void {
    compile.root_module.addImport("sokol", self.sokol_dep.module("sokol"));
    compile.root_module.addImport("cimgui", self.cimgui_dep.module("cimgui"));
    compile.root_module.addImport("rowmath", self.rowmath);
    compile.root_module.addImport(
        "stb_image",
        &self.stbi_dep.artifact("stb_image").root_module,
    );
}
