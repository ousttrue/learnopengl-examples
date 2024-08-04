pub const Example = struct {
    name: []const u8,
    root_source: []const u8,
    shader: ?[]const u8 = null,
};

pub const learnopengl_examples = [_]Example{
    .{
        .name = "learnopengl-examples",
        .root_source = "src/main.zig",
        .shader = "src/shaders/cube.glsl",
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
        .shader = "src/1-7-transformations/transformations.glsl",
    },
    .{
        .name = "1-8-1",
        .root_source = "src/1-8-coordinate-systems/1-plane.zig",
        .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-8-2",
        .root_source = "src/1-8-coordinate-systems/2-cube.zig",
        .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-8-3",
        .root_source = "src/1-8-coordinate-systems/3-more-cubes.zig",
        .shader = "src/1-8-coordinate-systems/shaders.glsl",
    },
    .{
        .name = "1-9-1",
        .root_source = "src/1-9-camera/1-lookat.zig",
        .shader = "src/1-9-camera/shaders.glsl",
    },
    .{
        .name = "1-9-2",
        .root_source = "src/1-9-camera/2-walk.zig",
        .shader = "src/1-9-camera/shaders.glsl",
    },
    .{
        .name = "1-9-3",
        .root_source = "src/1-9-camera/3-look.zig",
        .shader = "src/1-9-camera/shaders.glsl",
    },
    .{
        .name = "2-1-1",
        .root_source = "src/2-1-colors/1-scene.zig",
        .shader = "src/2-1-colors/shaders.glsl",
    },
    .{
        .name = "4-5-1",
        .root_source = "src/4-5-framebuffers/1-render-to-texture.zig",
        .shader = "src/4-5-framebuffers/1-render-to-texture.glsl",
    },
};

pub const sokol_examples = [_]Example{
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
    .{
        .name = "offscreen",
        .root_source = "sapp/offscreen-sapp.zig",
        .shader = "sapp/offscreen-sapp.glsl",
    },
    // .{
    //     .name = "ozz-skin",
    //     .root_source = "sapp/ozz-skin-sapp.zig",
    //     .shader = "sapp/ozz-skin-sapp.glsl",
    // },
    .{
        .name = "shapes-transform",
        .root_source = "sapp/shapes-transform-sapp.zig",
        .shader = "sapp/shapes-transform-sapp.glsl",
    },
    //
    //
    //
    // .{
    //     .name = "ozz-anim",
    //     .root_source = "sapp/ozz-anim-sapp.zig",
    // },
};
