pub const Asset = struct {
    from: []const u8,
    to: []const u8,
};

pub const Example = struct {
    name: []const u8,
    root_source: []const u8,
    shader: ?[]const u8 = null,
    c_srcs: ?[]const []const u8 = null,
    sidemodule: bool = false,
    assets: []const Asset = &.{},
};

pub const learnopengl_examples = [_]Example{
    .{
        .name = "1-3-1",
        .root_source = "learn_opengl/1-3-hello-window/1-rendering.zig",
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
        .name = "4-5-1",
        .root_source = "learn_opengl/4-5-framebuffers/1-render-to-texture.zig",
        .shader = "learn_opengl/4-5-framebuffers/1-render-to-texture.glsl",
        .assets = &.{
            .{ .from = "learn_opengl/assets/metal.png", .to = "metal.png" },
            .{ .from = "learn_opengl/assets/container.jpg", .to = "container.jpg" },
        },
    },
    //
    .{
        .name = "sokol-zig-imgui-sample",
        .root_source = "learn_opengl/sokol-zig-imgui-sample/main.zig",
    },
};

pub const sokol_examples = [_]Example{
    .{
        .name = "clear",
        .root_source = "sokol_examples/clear-sapp.zig",
    },
    .{
        .name = "triangle",
        .root_source = "sokol_examples/triangle-sapp.zig",
        .shader = "sokol_examples/triangle-sapp.glsl",
    },
    .{
        .name = "triangle-bufferless",
        .root_source = "sokol_examples/triangle-bufferless-sapp.zig",
        .shader = "sokol_examples/triangle-bufferless-sapp.glsl",
    },
    .{
        .name = "quad",
        .root_source = "sokol_examples/quad-sapp.zig",
        .shader = "sokol_examples/quad-sapp.glsl",
    },
    .{
        .name = "bufferoffsets",
        .root_source = "sokol_examples/bufferoffsets-sapp.zig",
        .shader = "sokol_examples/bufferoffsets-sapp.glsl",
    },
    .{
        .name = "cube",
        .root_source = "sokol_examples/cube-sapp.zig",
        .shader = "sokol_examples/cube-sapp.glsl",
    },
    .{
        .name = "noninterleaved",
        .root_source = "sokol_examples/noninterleaved-sapp.zig",
        .shader = "sokol_examples/noninterleaved-sapp.glsl",
    },
    .{
        .name = "texcube",
        .root_source = "sokol_examples/texcube-sapp.zig",
        .shader = "sokol_examples/texcube-sapp.glsl",
    },
    // - [ ] [vertexpull](sokol_examples/vertexpull-sapp.zig)
    // - [ ] [sbuftex](sokol_examples/sbuftex-sapp.zig)
    .{
        .name = "shapes",
        .root_source = "sokol_examples/shapes-sapp.zig",
        .shader = "sokol_examples/shapes-sapp.glsl",
    },
    .{
        .name = "shapes-transform",
        .root_source = "sokol_examples/shapes-transform-sapp.zig",
        .shader = "sokol_examples/shapes-transform-sapp.glsl",
    },
    .{
        .name = "offscreen",
        .root_source = "sokol_examples/offscreen-sapp.zig",
        .shader = "sokol_examples/offscreen-sapp.glsl",
    },
    // - [ ] [offscreen-msaa](sokol_examples/offscreen-msaa-sapp.zig)
    // - [ ] [instancing](sokol_examples/instancing-sapp.zig)
    // - [ ] [instancing-pull](sokol_examples/instancing-pull-sapp.zig)
    // - [ ] [mrt](sokol_examples/mrt-sapp.zig)
    // - [ ] [mrt-pixelformats](sokol_examples/mrt-pixelformats-sapp.zig)
    // - [ ] [arraytex](sokol_examples/arraytex-sapp.zig)
    // - [ ] [tex3d](sokol_examples/tex3d-sapp.zig)
    // - [ ] [dyntex3d](sokol_examples/dyntex3d-sapp.zig)
    // - [ ] [dyntex](sokol_examples/dyntex-sapp.zig)
    // - [ ] [basisu](sokol_examples/basisu-sapp.zig)
    // - [ ] [cubemap-jpeg](sokol_examples/cubemap-jpeg-sapp.zig)
    // - [ ] [cubemaprt](sokol_examples/cubemaprt-sapp.zig)
    // - [ ] [miprender](sokol_examples/miprender-sapp.zig)
    // - [ ] [layerrender](sokol_examples/layerrender-sapp.zig)
    // - [ ] [primtypes](sokol_examples/primtypes-sapp.zig)
    // - [ ] [uvwrap](sokol_examples/uvwrap-sapp.zig)
    // - [ ] [mipmap](sokol_examples/mipmap-sapp.zig)
    // - [ ] [uniformtypes](sokol_examples/uniformtypes-sapp.zig)
    // - [ ] [blend](sokol_examples/blend-sapp.zig)
    // - [ ] [sdf](sokol_examples/sdf-sapp.zig)
    // - [ ] [shadows](sokol_examples/shadows-sapp.zig)
    // - [ ] [shadows-depthtex](sokol_examples/shadows-depthtex-sapp.zig)
    // - [ ] [imgui](sokol_examples/imgui-sapp.zig)
    // - [ ] [imgui-dock](sokol_examples/imgui-dock-sapp.zig)
    // - [ ] [imgui-highdpi](sokol_examples/imgui-highdpi-sapp.zig)
    // - [ ] [cimgui](sokol_examples/cimgui-sapp.zig)
    // - [ ] [imgui-images](sokol_examples/imgui-images-sapp.zig)
    // - [ ] [imgui-usercallback](sokol_examples/imgui-usercallback-sapp.zig)
    // - [ ] [nuklear](sokol_examples/nuklear-sapp.zig)
    // - [ ] [nuklear-images](sokol_examples/nuklear-images-sapp.zig)
    // - [ ] [sgl-microui](sokol_examples/sgl-microui-sapp.zig)
    // - [ ] [fontstash](sokol_examples/fontstash-sapp.zig)
    // - [ ] [fontstash-layers](sokol_examples/fontstash-layers-sapp.zig)
    // - [ ] [debugtext](sokol_examples/debugtext-sapp.zig)
    // - [ ] [debugtext-printf](sokol_examples/debugtext-printf-sapp.zig)
    // - [ ] [debugtext-userfont](sokol_examples/debugtext-userfont-sapp.zig)
    // - [ ] [debugtext-context](sokol_examples/debugtext-context-sapp.zig)
    // - [ ] [debugtext-layers](sokol_examples/debugtext-layers-sapp.zig)
    // - [ ] [events](sokol_examples/events-sapp.zig)
    // - [ ] [icon](sokol_examples/icon-sapp.zig)
    // - [ ] [droptest](sokol_examples/droptest-sapp.zig)
    // - [ ] [pixelformats](sokol_examples/pixelformats-sapp.zig)
    // - [ ] [drawcallperf](sokol_examples/drawcallperf-sapp.zig)
    // - [ ] [saudio](sokol_examples/saudio-sapp.zig)
    // - [ ] [modplay](sokol_examples/modplay-sapp.zig)
    // - [ ] [noentry](sokol_examples/noentry-sapp.zig)
    // - [ ] [restart](sokol_examples/restart-sapp.zig)
    // - [ ] [sgl](sokol_examples/sgl-sapp.zig)
    .{
        .name = "sgl-lines",
        .root_source = "sokol_examples/sgl-lines-sapp.zig",
    },
    // - [ ] [sgl-points](sokol_examples/sgl-points-sapp.zig)
    // - [ ] [sgl-context](sokol_examples/sgl-context-sapp.zig)
    // - [ ] [loadpng](sokol_examples/loadpng-sapp.zig)
    // - [ ] [plmpeg](sokol_examples/plmpeg-sapp.zig)
    // - [ ] [cgltf](sokol_examples/cgltf-sapp.zig)
    .{
        .name = "ozz-anim",
        .root_source = "sokol_examples/ozz-anim-sapp.zig",
        .sidemodule = true,
        .assets = &.{
            .{ .from = "sokol_examples/data/ozz/ozz_anim_skeleton.ozz", .to = "ozz_anim_skeleton.ozz" },
            .{ .from = "sokol_examples/data/ozz/ozz_anim_animation.ozz", .to = "ozz_anim_animation.ozz" },
        },
    },
    .{
        .name = "ozz-skin",
        .root_source = "sokol_examples/ozz-skin-sapp.zig",
        .sidemodule = true,
        .shader = "sokol_examples/ozz-skin-sapp.glsl",
        .assets = &.{
            .{ .from = "sokol_examples/data/ozz/ozz_skin_skeleton.ozz", .to = "ozz_skin_skeleton.ozz" },
            .{ .from = "sokol_examples/data/ozz/ozz_skin_animation.ozz", .to = "ozz_skin_animation.ozz" },
            .{ .from = "sokol_examples/data/ozz/ozz_skin_mesh.ozz", .to = "ozz_skin_mesh.ozz" },
        },
    },
    // - [ ] [ozz-storagebuffer](sokol_examples/ozz-storagebuffer-sapp.zig)
    // - [ ] [shdfeatures](sokol_examples/shdfeatures-sapp.zig)
    // - [ ] [spine-simple](sokol_examples/spine-simple-sapp.zig)
    // - [ ] [spine-inspector](sokol_examples/spine-inspector-sapp.zig)
    // - [ ] [spine-layers](sokol_examples/spine-layers-sapp.zig)
    // - [ ] [spine-skinsets](sokol_examples/spine-skinsets-sapp.zig)
    // - [ ] [spine-switch-skinsets](sokol_examples/spine-switch-skinsets-sapp.zig)
};

pub const all_examples = learnopengl_examples ++ sokol_examples;
