const std = @import("std");
const build_examples = @import("build_examples.zig");
const Deps = @import("Deps.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const deps = Deps.init(b, target, optimize);

    for (build_examples.examples) |example| {
        const exe = b.addExecutable(.{
            .target = target,
            .optimize = optimize,
            .name = example.name,
            .root_source_file = b.path(example.root_source),
        });
        b.installArtifact(exe);

        deps.inject_dependencies(b, exe);
    }
}
