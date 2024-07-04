const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .target = target,
        .optimize = optimize,
        .name = "learnopengl-examples",
        .root_source_file = b.path("src/main.zig"),
    });
    b.installArtifact(exe);
    exe.root_module.addImport("sokol", dep_sokol.module("sokol"));

    {
        const example = b.addExecutable(.{
            .target = target,
            .optimize = optimize,
            .name = "1-3-hello-window",
            .root_source_file = b.path("src/1-3-hello-window/1-rendering.zig"),
        });
        b.installArtifact(example);
        example.root_module.addImport("sokol", dep_sokol.module("sokol"));
    }
}
