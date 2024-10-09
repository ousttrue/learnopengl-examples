const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    if (b.option(bool, "sample1", "port from zeromake/learnopengl-examples") orelse false) {
        const dep = b.dependency("learn_opengl_zero", .{
            .target = target,
            .optimize = optimize,
        });
        _ = dep;
    }

    if (b.option(bool, "sample2", "port from JoeyDeVries/LearnOpenGL") orelse false) {
        const dep = b.dependency("learn_opengl_joey", .{
            .target = target,
            .optimize = optimize,
        });

        if (target.result.isWasm()) {
            const wf = dep.namedWriteFiles("web");
            b.installDirectory(.{
                .source_dir = wf.getDirectory(),
                .install_dir = .{ .prefix = void{} },
                .install_subdir = "web",
            });
        } else {
            for (dep.builder.install_tls.step.dependencies.items) |dep_step| {
                if (dep_step.cast(std.Build.Step.InstallArtifact)) |install_artifact| {
                    const install = b.addInstallArtifact(install_artifact.artifact, .{});
                    b.getInstallStep().dependOn(&install.step);

                    const run = b.addRunArtifact(install_artifact.artifact);
                    run.step.dependOn(&install.step);

                    b.step(
                        b.fmt("run-{s}", .{install_artifact.artifact.name}),
                        b.fmt("Run {s}", .{install_artifact.artifact.name}),
                    ).dependOn(&run.step);
                }
            }
        }
    }

    // const deps = Deps.init(b, target, optimize);
    //
    // const wf = deps.dep_ozz.namedWriteFiles("meson_build");
    // const install = b.addInstallDirectory(.{
    //     .install_dir = .{ .prefix = void{} },
    //     .install_subdir = "",
    //     .source_dir = wf.getDirectory(),
    // });
    //
    // if (target.result.isWasm()) {
    //     const dep_emsdk = b.dependency("emsdk-zig", .{}).builder.dependency("emsdk", .{});
    //
    //     buildWasm(b, target, optimize, &deps, &examples.all_examples, dep_emsdk, &install.step);
    // } else {
    //     buildNative(b, target, optimize, &deps, &examples.all_examples, &install.step);
    // }
}
