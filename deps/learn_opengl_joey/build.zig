const std = @import("std");
const builtin = @import("builtin");
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

        for (example.shaders) |shader| {
            const shdc = sokolShdc(b, target, shader);
            compile.step.dependOn(shdc);
        }

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

// a separate step to compile shaders
pub fn sokolShdc(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    shader: []const u8,
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
        b.fmt("{s}.zig", .{shader}),
        "-l",
        slang,
        "-f",
        "sokol_zig",
    }).step;
}
