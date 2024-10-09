pub const Asset = struct {
    from: []const u8,
    to: []const u8,
};

pub const Example = struct {
    name: []const u8,
    label: ?[]const u8 = null,
    root_source: []const u8,
    shader: ?[]const u8 = null,
    c_includes: []const []const u8 = &.{},
    c_sources: []const []const u8 = &.{},
    sidemodule: bool = false,
    assets: []const Asset = &.{},
};

pub const learnopengl_examples = [_]Example{
    .{
        .name = "1-3-1",
        .root_source = "learn_opengl/1-3-hello-window/1-rendering.zig",
    },
    .{
        .name = "hello_triangle",
        .root_source = "learn_opengl/1/2-1/hello_triangle.zig",
        .shader = "learn_opengl/1/2-1/hello_triangle.glsl",
    },
    .{
        .name = "1-4-1",
        .root_source = "learn_opengl/1-4-hello-triangle/1-triangle.zig",
        .shader = "learn_opengl/1-4-hello-triangle/1-triangle.glsl",
    },
    .{
        .name = "1-4-2",
        .root_source = "learn_opengl/1-4-hello-triangle/2-quad.zig",
        .shader = "learn_opengl/1-4-hello-triangle/2-quad.glsl",
    },
    .{
        .name = "1-4-3",
        .root_source = "learn_opengl/1-4-hello-triangle/3-quad-wireframe.zig",
        .shader = "learn_opengl/1-4-hello-triangle/3-quad-wireframe.glsl",
    },
    .{
        .name = "1-5-1",
        .root_source = "learn_opengl/1-5-shaders/1-in-out.zig",
        .shader = "learn_opengl/1-5-shaders/1-in-out.glsl",
    },
    .{
        .name = "1-5-2",
        .root_source = "learn_opengl/1-5-shaders/2-uniforms.zig",
        .shader = "learn_opengl/1-5-shaders/2-uniforms.glsl",
    },
    .{
        .name = "1-5-3",
        .root_source = "learn_opengl/1-5-shaders/3-attributes.zig",
        .shader = "learn_opengl/1-5-shaders/3-attributes.glsl",
    },
    .{
        .name = "1-6-1",
        .root_source = "learn_opengl/1-6-textures/1-texture.zig",
        .shader = "learn_opengl/1-6-textures/1-texture.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
        },
    },
    .{
        .name = "1-6-2",
        .root_source = "learn_opengl/1-6-textures/2-texture-blend.zig",
        .shader = "learn_opengl/1-6-textures/2-texture-blend.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
        },
    },
    .{
        .name = "1-6-3",
        .root_source = "learn_opengl/1-6-textures/3-multiple-textures.zig",
        .shader = "learn_opengl/1-6-textures/3-multiple-textures.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-7-3",
        .root_source = "learn_opengl/1-7-transformations/1-scale-rotate.zig",
        .shader = "learn_opengl/1-7-transformations/transformations.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-7-2",
        .root_source = "learn_opengl/1-7-transformations/2-rotate-translate.zig",
        .shader = "learn_opengl/1-7-transformations/transformations.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-8-1",
        .root_source = "learn_opengl/1-8-coordinate-systems/1-plane.zig",
        .shader = "learn_opengl/1-8-coordinate-systems/shaders.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-8-2",
        .root_source = "learn_opengl/1-8-coordinate-systems/2-cube.zig",
        .shader = "learn_opengl/1-8-coordinate-systems/shaders.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-8-3",
        .root_source = "learn_opengl/1-8-coordinate-systems/3-more-cubes.zig",
        .shader = "learn_opengl/1-8-coordinate-systems/shaders.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-9-1",
        .root_source = "learn_opengl/1-9-camera/1-lookat.zig",
        .shader = "learn_opengl/1-9-camera/shaders.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-9-2",
        .root_source = "learn_opengl/1-9-camera/2-walk.zig",
        .shader = "learn_opengl/1-9-camera/shaders.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "1-9-3",
        .root_source = "learn_opengl/1-9-camera/3-look.zig",
        .shader = "learn_opengl/1-9-camera/shaders.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
            .{ .from = "learn_opengl/assets/awesomeface.png", .to = "awesomeface.png" },
        },
    },
    .{
        .name = "2-1-1",
        .root_source = "learn_opengl/2-1-colors/1-scene.zig",
        .shader = "learn_opengl/2-1-colors/shaders.glsl",
    },
    .{
        .name = "2-2-1",
        .root_source = "learn_opengl/2-2-basic-lighting/1-ambient.zig",
        .shader = "learn_opengl/2-2-basic-lighting/1-ambient.glsl",
    },
    .{
        .name = "4-5-1",
        .root_source = "learn_opengl/4-5-framebuffers/1-render-to-texture.zig",
        .shader = "learn_opengl/4-5-framebuffers/1-render-to-texture.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/metal.png", .to = "metal.png" },
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
        },
    },
};

pub const all_examples = learnopengl_examples;
