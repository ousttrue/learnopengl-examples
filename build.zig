const std = @import("std");
const builtin = @import("builtin");

const examples = [_]struct {
    name: []const u8,
    root_source: []const u8,
    shader: ?[]const u8 = null,
}{
    .{
        .name = "1-3-hello-window",
        .root_source = "src/1-3-hello-window/1-rendering.zig",
    },
    .{
        .name = "1-4-1-triangle",
        .root_source = "src/1-4-hello-triangle/1-triangle.zig",
        .shader = "src/1-4-hello-triangle/1-triangle.glsl",
    },
    .{
        .name = "1-4-2-quad",
        .root_source = "src/1-4-hello-triangle/2-quad.zig",
        .shader = "src/1-4-hello-triangle/2-quad.glsl",
    },
    .{
        .name = "1-4-3-quad-wireframe",
        .root_source = "src/1-4-hello-triangle/3-quad-wireframe.zig",
        .shader = "src/1-4-hello-triangle/3-quad-wireframe.glsl",
    },
    .{
        .name = "1-5-1-in-out",
        .root_source = "src/1-5-shaders/1-in-out.zig",
        .shader = "src/1-5-shaders/1-in-out.glsl",
    },
    .{
        .name = "1-5-2-uniforms",
        .root_source = "src/1-5-shaders/2-uniforms.zig",
        .shader = "src/1-5-shaders/2-uniforms.glsl",
    },
    .{
        .name = "1-5-3-attributes",
        .root_source = "src/1-5-shaders/3-attributes.zig",
        .shader = "src/1-5-shaders/3-attributes.glsl",
    },
    .{
        .name = "1-6-1-texture",
        .root_source = "src/1-6-textures/1-texture.zig",
        .shader = "src/1-6-textures/1-texture.glsl",
    },
    .{
        .name = "1-6-2-texture-blend",
        .root_source = "src/1-6-textures/2-texture-blend.zig",
        .shader = "src/1-6-textures/2-texture-blend.glsl",
    },
    .{
        .name = "1-6-3-multiple-textures",
        .root_source = "src/1-6-textures/3-multiple-textures.zig",
        .shader = "src/1-6-textures/3-multiple-textures.glsl",
    },
    .{
        .name = "1-7-3-scale-rotate",
        .root_source = "src/1-7-transformations/1-scale-rotate.zig",
        .shader = "src/1-7-transformations/transformations.glsl",
    },
    .{
        .name = "1-7-2-rotate-translate",
        .root_source = "src/1-7-transformations/2-rotate-translate.zig",
        // .shader = "src/1-7-transformations/transformations.glsl",
    },
    .{
        .name = "1-8-1-plane",
        .root_source = "src/1-8-coordinate-systems/1-plane.zig",
        .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-8-2-cube",
        .root_source = "src/1-8-coordinate-systems/2-cube.zig",
        // .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-8-3-more-cubes",
        .root_source = "src/1-8-coordinate-systems/3-more-cubes.zig",
        // .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
};

// a separate step to compile shaders, expects the shader compiler in ../sokol-tools-bin/
// TODO: install sokol-shdc via package manager
fn buildShader(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    shdc_step: *std.Build.Step,
    comptime sokol_tools_bin_dir: []const u8,
    comptime shader: []const u8,
) void {
    const optional_shdc: ?[:0]const u8 = comptime switch (builtin.os.tag) {
        .windows => "win32/sokol-shdc.exe",
        .linux => "linux/sokol-shdc",
        .macos => if (builtin.cpu.arch.isX86()) "osx/sokol-shdc" else "osx_arm64/sokol-shdc",
        else => null,
    };
    if (optional_shdc == null) {
        std.log.warn("unsupported host platform, skipping shader compiler step", .{});
        return;
    }
    const shdc_path = sokol_tools_bin_dir ++ optional_shdc.?;
    const glsl = if (target.result.isDarwin()) "glsl410" else "glsl430";
    const slang = glsl ++ ":metal_macos:hlsl5:glsl300es:wgsl";
    const cmd = b.addSystemCommand(&.{
        shdc_path,
        "-i",
        shader,
        "-o",
        shader ++ ".zig",
        "-l",
        slang,
        "-f",
        "sokol_zig",
    });
    shdc_step.dependOn(&cmd.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    {
        const exe = b.addExecutable(.{
            .target = target,
            .optimize = optimize,
            .name = "learnopengl-examples",
            .root_source_file = b.path("src/main.zig"),
        });
        b.installArtifact(exe);
        exe.root_module.addImport("sokol", dep_sokol.module("sokol"));
    }

    const helper = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/sokol_helper/main.zig"),
    });
    helper.addImport("sokol", dep_sokol.module("sokol"));

    const szmath = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/math.zig"),
    });

    const shdc_step = b.step("shaders", "Compile shaders (needs ../sokol-tools-bin)");
    inline for (examples) |example| {
        const exe = b.addExecutable(.{
            .target = target,
            .optimize = optimize,
            .name = example.name,
            .root_source_file = b.path(example.root_source),
        });
        b.installArtifact(exe);
        exe.root_module.addImport("sokol", dep_sokol.module("sokol"));
        if (example.shader) |shader| {
            buildShader(b, target, shdc_step, "../../floooh/sokol-tools-bin/bin/", shader);
        }
        exe.root_module.addImport("sokol_helper", helper);
        exe.root_module.addImport("szmath", szmath);

        exe.addIncludePath(b.path("c"));
        exe.addCSourceFile(.{ .file = b.path("c/stb_image.c") });
        exe.linkLibC();
    }
}
