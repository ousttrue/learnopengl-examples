const std = @import("std");
const builtin = @import("builtin");

pub fn buildWasm(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    dep_emsdk: *std.Build.Dependency,
    dep: ?*std.Build.Step,
) !*std.Build.Step {
    const builddir = "build_wasm";
    const prefix = b.path("zig-out").getPath(b);

    var output_file = try std.fs.cwd().createFile(b.path("sidemodule/emsdk.ini").getPath(b), .{});
    defer output_file.close();
    const ext: []const u8 = if (builtin.os.tag == .windows) ".bat" else "";
    try output_file.writeAll(b.fmt(
        \\# wasm.ini
        \\[constants]
        \\args = []
        \\
        \\[binaries]
        \\c = '{s}'
        \\cpp = '{s}'
        \\ar = '{s}'
        \\strip = '{s}'
        \\
        \\[built-in options]
        \\c_args = []
        \\c_link_args = args
        \\cpp_args = []
        \\cpp_link_args = args
        \\default_library = 'static'
        \\
        \\[host_machine]
        \\system = 'emscripten'
        \\cpu_family = 'wasm'
        \\cpu = 'wasm'
        \\endian = 'little'
    , .{
        dep_emsdk.path(b.fmt("upstream/emscripten/emcc{s}", .{ext})).getPath(b),
        dep_emsdk.path(b.fmt("upstream/emscripten/em++{s}", .{ext})).getPath(b),
        dep_emsdk.path(b.fmt("upstream/emscripten/emar{s}", .{ext})).getPath(b),
        dep_emsdk.path(b.fmt("upstream/emscripten/emstrip{s}", .{ext})).getPath(b),
    }));

    // meson setup --compilation emsdk.ini
    const meson_setup = b.addSystemCommand(&.{"meson"});
    if (dep) |d| {
        meson_setup.step.dependOn(d);
    }
    meson_setup.cwd = b.path("sidemodule");
    meson_setup.addArgs(&.{
        "setup",
        builddir,
        if (optimize == .Debug) "-Dbuildtype=debug" else "-Dbuildtype=release",
        "--prefix",
        prefix,
        // "--reconfigure",
        "--cross-file",
        "emsdk.ini",
    });

    // meson install
    const meson_install = b.addSystemCommand(&.{"meson"});
    meson_install.step.dependOn(&meson_setup.step);
    meson_install.cwd = b.path("sidemodule");
    meson_install.addArgs(&.{
        "install",
        "-C",
        builddir,
    });
    // => zig-out/bin/sidemodule.wasm

    return &meson_install.step;
}

fn mesonSetupNative(b: *std.Build, builddir: []const u8, prefix: []const u8) *std.Build.Step {
    const tool_run = b.addSystemCommand(&.{"meson"});
    tool_run.cwd = b.path("sidemodule");
    tool_run.addArgs(&.{
        "setup",
        builddir,
        "--prefix",
        prefix,
        // "--reconfigure",
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
