const std = @import("std");

pub fn buildWasm(b: *std.Build) *std.Build.Step {
    _ = b; // autofix
    // sidemodule
    // generate: meson cross-file emsdk.ini
    // meson setup --compilation emsdk.ini
    // meson install
    // emcc main.c -s MAIN_MODULE=1 -o main.html -s "RUNTIME_LINKED_LIBS=['sidemodule.wasm']"
    unreachable;
}

fn mesonSetupNative(b: *std.Build, builddir: []const u8, prefix: []const u8) *std.Build.Step {
    const tool_run = b.addSystemCommand(&.{"meson"});
    tool_run.cwd = b.path("sidemodule");
    tool_run.addArgs(&.{
        "setup",
        builddir,
        "--prefix",
        prefix,
        "--reconfigure",
    });
    return &tool_run.step;
}

fn mesonBUild(b: *std.Build, builddir: []const u8) *std.Build.Step {
    const tool_run = b.addSystemCommand(&.{"meson"});
    tool_run.cwd = b.path("sidemodule");
    tool_run.addArgs(&.{
        "install",
        "-C",
        builddir,
    });
    return &tool_run.step;
}

pub fn buildNative(b: *std.Build) *std.Build.Step {
    const builddir = "build_native";
    const meson_setup = mesonSetupNative(b, builddir, b.path("zig-out").getPath(b));
    const meson_build = mesonBUild(b, builddir);
    meson_build.dependOn(meson_setup);
    return meson_build;
}
