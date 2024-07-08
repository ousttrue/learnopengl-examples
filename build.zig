const std = @import("std");
const builtin = @import("builtin");
const sokol = @import("sokol");

const examples = [_]struct {
    name: []const u8,
    root_source: []const u8,
    shader: ?[]const u8 = null,
}{
    .{
        .name = "learnopengl-examples",
        .root_source = "src/main.zig",
    },
    .{
        .name = "1-3-1",
        .root_source = "src/1-3-hello-window/1-rendering.zig",
    },
    .{
        .name = "1-4-1",
        .root_source = "src/1-4-hello-triangle/1-triangle.zig",
        .shader = "src/1-4-hello-triangle/1-triangle.glsl",
    },
    .{
        .name = "1-4-2",
        .root_source = "src/1-4-hello-triangle/2-quad.zig",
        .shader = "src/1-4-hello-triangle/2-quad.glsl",
    },
    .{
        .name = "1-4-3",
        .root_source = "src/1-4-hello-triangle/3-quad-wireframe.zig",
        .shader = "src/1-4-hello-triangle/3-quad-wireframe.glsl",
    },
    .{
        .name = "1-5-1",
        .root_source = "src/1-5-shaders/1-in-out.zig",
        .shader = "src/1-5-shaders/1-in-out.glsl",
    },
    .{
        .name = "1-5-2",
        .root_source = "src/1-5-shaders/2-uniforms.zig",
        .shader = "src/1-5-shaders/2-uniforms.glsl",
    },
    .{
        .name = "1-5-3",
        .root_source = "src/1-5-shaders/3-attributes.zig",
        .shader = "src/1-5-shaders/3-attributes.glsl",
    },
    .{
        .name = "1-6-1",
        .root_source = "src/1-6-textures/1-texture.zig",
        .shader = "src/1-6-textures/1-texture.glsl",
    },
    .{
        .name = "1-6-2",
        .root_source = "src/1-6-textures/2-texture-blend.zig",
        .shader = "src/1-6-textures/2-texture-blend.glsl",
    },
    .{
        .name = "1-6-3",
        .root_source = "src/1-6-textures/3-multiple-textures.zig",
        .shader = "src/1-6-textures/3-multiple-textures.glsl",
    },
    .{
        .name = "1-7-3",
        .root_source = "src/1-7-transformations/1-scale-rotate.zig",
        .shader = "src/1-7-transformations/transformations.glsl",
    },
    .{
        .name = "1-7-2",
        .root_source = "src/1-7-transformations/2-rotate-translate.zig",
        // .shader = "src/1-7-transformations/transformations.glsl",
    },
    .{
        .name = "1-8-1",
        .root_source = "src/1-8-coordinate-systems/1-plane.zig",
        .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-8-2",
        .root_source = "src/1-8-coordinate-systems/2-cube.zig",
        // .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-8-3",
        .root_source = "src/1-8-coordinate-systems/3-more-cubes.zig",
        // .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-9-1",
        .root_source = "src/1-9-camera/1-lookat.zig",
        .shader = "src/1-9-camera/shaders.glsl",
    },
    .{
        .name = "1-9-2",
        .root_source = "src/1-9-camera/2-walk.zig",
        // .shader = "src/1-9-camera/shaders.glsl",
    },
    .{
        .name = "1-9-3",
        .root_source = "src/1-9-camera/3-look.zig",
        // .shader = "src/1-9-camera/shaders.glsl",
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

    const stb_image = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("c/stb_image.zig"),
    });

    const shdc_step = b.step("shaders", "Compile shaders (needs ../sokol-tools-bin)");
    inline for (examples) |example| {
        if (example.shader) |shader| {
            buildShader(b, target, shdc_step, "../../floooh/sokol-tools-bin/bin/", shader);
        }

        const compile = if (target.result.isWasm()) wasm: {
            const lib = b.addStaticLibrary(.{
                .target = target,
                .optimize = optimize,
                .name = example.name,
                .root_source_file = b.path(example.root_source),
            });
            // exe.entry = .disabled;
            break :wasm lib;
        } else native: {
            const exe = b.addExecutable(.{
                .target = target,
                .optimize = optimize,
                .name = example.name,
                .root_source_file = b.path(example.root_source),
            });
            exe.addCSourceFile(.{ .file = b.path("c/stb_image.c") });
            break :native exe;
        };
        b.installArtifact(compile);
        compile.root_module.addImport("sokol", dep_sokol.module("sokol"));
        compile.root_module.addImport("sokol_helper", helper);
        compile.root_module.addImport("szmath", szmath);
        compile.root_module.addImport("stb_image", stb_image);
        compile.linkLibC();
        if (target.result.isWasm()) {
            // create a build step which invokes the Emscripten linker
            const emsdk = dep_sokol.builder.dependency("emsdk", .{});
            _ = try sokol.emLinkStep(b, .{
                .lib_main = compile,
                .target = target,
                .optimize = optimize,
                .emsdk = emsdk,
                .use_webgl2 = true,
                .use_emmalloc = true,
                .use_filesystem = false,
                .shell_file_path = dep_sokol.path("src/sokol/web/shell.html").getPath(b),
                .extra_args = &.{
                    // "-sERROR_ON_UNDEFINED_SYMBOLS=0",
                    "-sSTB_IMAGE=1",
                },
            });
        }
    }
}
