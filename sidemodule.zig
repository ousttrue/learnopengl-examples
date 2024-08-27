const std = @import("std");
const builtin = @import("builtin");

pub fn crossFile(
    b: *std.Build,
    wf: *std.Build.Step.WriteFile,
    dep_emsdk: *std.Build.Dependency,
) std.Build.LazyPath {
    const ext: []const u8 = if (builtin.os.tag == .windows) ".bat" else "";
    return wf.add("emsdk.ini", b.fmt(
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
}

pub fn mesonWasm(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    dep_emsdk: *std.Build.Dependency,
) !*std.Build.Step {
    const builddir = "build_wasm";

    // meson install
    const meson_install = b.addSystemCommand(&.{"meson"});
    meson_install.cwd = b.path("sidemodule");
    meson_install.addArgs(&.{
        "install",
        "-C",
        builddir,
    });
    // => zig-out/bin/sidemodule.wasm

    const setup_dir = b.path(b.fmt("sidemodule/{s}", .{builddir})).getPath(b);
    // std.debug.print("mesonWasm => {s}\n", .{setup_dir});
    if (std.fs.openDirAbsolute(setup_dir, .{})) |*dir| {
        @constCast(dir).close();
    } else |_| {
        // meson setup --cross-file emsdk.ini
        const prefix = b.path("zig-out").getPath(b);
        const wf = b.addWriteFiles();
        const ini = crossFile(b, wf, dep_emsdk);
        const meson_setup = b.addSystemCommand(&.{"meson"});
        meson_setup.cwd = b.path("sidemodule");
        meson_setup.addArgs(&.{
            "setup",
            builddir,
            if (optimize == .Debug) "-Dbuildtype=debug" else "-Dbuildtype=release",
            "--prefix",
            prefix,
            // "--reconfigure",
            "--cross-file",
        });
        meson_setup.addFileInput(ini);
        meson_install.step.dependOn(&meson_setup.step);
    }

    return &meson_install.step;
}

pub fn mesonNative(b: *std.Build) *std.Build.Step {
    const builddir = "build_native";

    const meson_install = b.addSystemCommand(&.{"meson"});
    meson_install.cwd = b.path("sidemodule");
    meson_install.addArgs(&.{
        "install",
        "-C",
        builddir,
    });
    // => zig-out/bin/sidemodule.dll

    const setup_dir = b.path(b.fmt("sidemodule/{s}", .{builddir})).getPath(b);
    // std.debug.print("mesonWasm => {s}\n", .{setup_dir});
    if (std.fs.openDirAbsolute(setup_dir, .{})) |*dir| {
        @constCast(dir).close();
    } else |_| {
        const prefix = b.path("zig-out").getPath(b);
        const meson_setup = b.addSystemCommand(&.{"meson"});
        meson_setup.cwd = b.path("sidemodule");
        meson_setup.addArgs(&.{
            "setup",
            builddir,
            "--prefix",
            prefix,
            // "--reconfigure",
        });
        meson_install.step.dependOn(&meson_setup.step);
    }

    return &meson_install.step;
}
