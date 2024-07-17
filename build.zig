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
        .name = "sokol-zig-imgui-sample",
        .root_source = "src/sokol-zig-imgui-sample/main.zig",
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
    .{
        .name = "4-5-1",
        .root_source = "src/4-5-framebuffers/1-render-to-texture.zig",
        .shader = "src/4-5-framebuffers/1-render-to-texture.glsl",
    },
};

const sokol_apps = [_]struct {
    name: []const u8,
    root_source: []const u8,
    shader: ?[]const u8 = null,
}{
    .{
        .name = "clear",
        .root_source = "sapp/clear-sapp.zig",
    },
    .{
        .name = "triangle",
        .root_source = "sapp/triangle-sapp.zig",
        .shader = "sapp/triangle-sapp.glsl",
    },
    .{
        .name = "triangle-bufferless",
        .root_source = "sapp/triangle-bufferless-sapp.zig",
        .shader = "sapp/triangle-bufferless-sapp.glsl",
    },
    .{
        .name = "quad",
        .root_source = "sapp/quad-sapp.zig",
        .shader = "sapp/quad-sapp.glsl",
    },
    .{
        .name = "bufferoffsets-sapp",
        .root_source = "sapp/bufferoffsets-sapp.zig",
        .shader = "sapp/bufferoffsets-sapp.glsl",
    },
    .{
        .name = "cube",
        .root_source = "sapp/cube-sapp.zig",
        .shader = "sapp/cube-sapp.glsl",
    },
    .{
        .name = "noninterleaved",
        .root_source = "sapp/noninterleaved-sapp.zig",
        .shader = "sapp/noninterleaved-sapp.glsl",
    },
    .{
        .name = "texcube",
        .root_source = "sapp/texcube-sapp.zig",
        .shader = "sapp/texcube-sapp.glsl",
    },
    .{
        .name = "sgl-lines",
        .root_source = "sapp/sgl-lines-sapp.zig",
    },
    //
    //
    //
    .{
        .name = "ozz-anim",
        .root_source = "sapp/ozz-anim-sapp.zig",
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

const Deps = struct {
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    shdc_step: *std.Build.Step,
    dep_sokol: *std.Build.Dependency,
    dep_cimgui: *std.Build.Dependency,
    helper: *std.Build.Module,
    szmath: *std.Build.Module,
    stb_image: *std.Build.Module,
    lopgl: *std.Build.Module,
    dbgui: *std.Build.Module,
    util_camera: *std.Build.Module,

    fn init(b: *std.Build) @This() {
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});

        var deps = @This(){
            .b = b,
            .target = target,
            .optimize = optimize,
            .shdc_step = b.step("shaders", "Compile shaders (needs ../sokol-tools-bin)"),
            .dep_sokol = b.dependency("sokol", .{
                .target = target,
                .optimize = optimize,
                .with_sokol_imgui = true,
            }),
            .dep_cimgui = b.dependency("cimgui", .{
                .target = target,
                .optimize = optimize,
            }),
            .helper = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("src/sokol_helper/main.zig"),
            }),
            .szmath = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("src/math.zig"),
            }),
            .stb_image = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("c/stb_image.zig"),
            }),
            .lopgl = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("src/lopgl_app.zig"),
            }),
            .dbgui = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("sapp/libs/dbgui/dbgui.zig"),
            }),
            .util_camera = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("sapp/libs/util/camera.zig"),
            }),
        };

        // inject the cimgui header search path into the sokol C library compile step
        const cimgui_root = deps.dep_cimgui.namedWriteFiles("cimgui").getDirectory();
        deps.dep_sokol.artifact("sokol_clib").addIncludePath(cimgui_root);
        deps.helper.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.lopgl.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.lopgl.addImport("szmath", deps.szmath);
        deps.dbgui.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.util_camera.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.util_camera.addImport("szmath", deps.szmath);

        return deps;
    }

    fn compile_example(
        self: *@This(),
        name: []const u8,
        root_source: []const u8,
        comptime _shader: ?[]const u8,
    ) void {
        if (_shader) |shader| {
            buildShader(self.b, self.target, self.shdc_step, "../../floooh/sokol-tools-bin/bin/", shader);
        }
        const compile = if (self.target.result.isWasm()) wasm: {
            const lib = self.b.addStaticLibrary(.{
                .target = self.target,
                .optimize = self.optimize,
                .name = name,
                .root_source_file = self.b.path(root_source),
            });

            break :wasm lib;
        } else native: {
            const exe = self.b.addExecutable(.{
                .target = self.target,
                .optimize = self.optimize,
                .name = name,
                .root_source_file = self.b.path(root_source),
            });
            exe.addCSourceFile(.{ .file = self.b.path("c/stb_image.c") });
            break :native exe;
        };
        self.b.installArtifact(compile);
        compile.root_module.addImport("sokol", self.dep_sokol.module("sokol"));
        compile.root_module.addImport("sokol_helper", self.helper);
        compile.root_module.addImport("szmath", self.szmath);
        compile.root_module.addImport("stb_image", self.stb_image);
        compile.root_module.addImport("cimgui", self.dep_cimgui.module("cimgui"));
        compile.root_module.addImport("lopgl", self.lopgl);
        compile.root_module.addImport("dbgui", self.dbgui);
        compile.root_module.addImport("util_camera", self.util_camera);
        compile.linkLibC();

        compile.addIncludePath(self.b.path("sapp/libs/ozzanim/include"));
        compile.addCSourceFile(.{ .file = self.b.path("sapp/ozz_wrap.cpp") });

        compile.addCSourceFiles(.{
            .files = &.{
                "sapp/libs/ozzanim/src/ozz_animation.cc",
                "sapp/libs/ozzanim/src/ozz_base.cc",
            },
        });

        if (self.target.result.isWasm()) {
            // create a build step which invokes the Emscripten linker
            const dep_emsdk = self.dep_sokol.builder.dependency("emsdk", .{});
            _ = try sokol.emLinkStep(self.b, .{
                .lib_main = compile,
                .target = self.target,
                .optimize = self.optimize,
                .emsdk = dep_emsdk,
                .use_webgl2 = true,
                .use_emmalloc = true,
                .use_filesystem = false,
                .shell_file_path = self.dep_sokol.path("src/sokol/web/shell.html").getPath(self.b),
                .extra_args = &.{
                    // "-sERROR_ON_UNDEFINED_SYMBOLS=0",
                    "-sSTB_IMAGE=1",
                },
            });

            // need to inject the Emscripten system header include path into
            // the cimgui C library otherwise the C/C++ code won't find
            // C stdlib headers
            const emsdk_incl_path = dep_emsdk.path("upstream/emscripten/cache/sysroot/include");
            self.dep_cimgui.artifact("cimgui_clib").addSystemIncludePath(emsdk_incl_path);

            // all C libraries need to depend on the sokol library, when building for
            // WASM this makes sure that the Emscripten SDK has been setup before
            // C compilation is attempted (since the sokol C library depends on the
            // Emscripten SDK setup step)
            self.dep_cimgui.artifact("cimgui_clib").step.dependOn(&self.dep_sokol.artifact("sokol_clib").step);
        }
    }
};

pub fn build(b: *std.Build) void {
    var deps = Deps.init(b);
    inline for (examples) |example| {
        deps.compile_example(
            example.name,
            example.root_source,
            example.shader,
        );
    }
    inline for (sokol_apps) |example| {
        deps.compile_example(
            example.name,
            example.root_source,
            example.shader,
        );
    }
}
