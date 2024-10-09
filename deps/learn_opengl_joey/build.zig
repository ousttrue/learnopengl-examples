const std = @import("std");
const build_examples = @import("build_examples.zig");
const Deps = @import("Deps.zig");
const build_wasm = @import("build_wasm.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const deps = Deps.init(b, target, optimize);

    const wf = b.addNamedWriteFiles("web");

    for (build_examples.examples) |example| {
        const compile = if (target.result.isWasm())
            b.addStaticLibrary(.{
                .target = target,
                .optimize = optimize,
                .name = example.name,
                .root_source_file = b.path(example.root_source),
                .pic = true,
            })
        else
            b.addExecutable(.{
                .target = target,
                .optimize = optimize,
                .name = example.name,
                .root_source_file = b.path(example.root_source),
            });

        deps.inject_dependencies(b, compile);

        if (target.result.isWasm()) {
            // copy wasm to NamedWriteFiles
            const wasm = build_wasm.emLink(b, target, optimize, compile, &deps);
            _ = wf.addCopyDirectory(wasm.dirname(), "", .{});
        } else {
            // install artifact
            b.installArtifact(compile);
        }
    }
}
