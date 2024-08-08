pub const Example = struct {
    name: []const u8,
    root_source: []const u8,
    shader: ?[]const u8 = null,
    c_srcs: ?[]const []const u8 = null,
    sidemodule: bool = false,
    assets: []const []const u8 = &.{},
};

pub const learnopengl_examples = [_]Example{
    // .{
    //     .name = "main",
    //     .root_source = "src/main.zig",
    //     .shader = "src/shaders/cube.glsl",
    //     // .c_srcs = &.{
    //     //     "src/main.cpp",
    //     // },
    // },
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
    // - [ ] [vertexpull](sapp/vertexpull-sapp.zig)
    // - [ ] [sbuftex](sapp/sbuftex-sapp.zig)
    // - [ ] [shapes](sapp/shapes-sapp.zig)
    .{
        .name = "shapes-transform",
        .root_source = "sapp/shapes-transform-sapp.zig",
        .shader = "sapp/shapes-transform-sapp.glsl",
    },
    .{
        .name = "offscreen",
        .root_source = "sapp/offscreen-sapp.zig",
        .shader = "sapp/offscreen-sapp.glsl",
    },
    // - [ ] [offscreen-msaa](sapp/offscreen-msaa-sapp.zig)
    // - [ ] [instancing](sapp/instancing-sapp.zig)
    // - [ ] [instancing-pull](sapp/instancing-pull-sapp.zig)
    // - [ ] [mrt](sapp/mrt-sapp.zig)
    // - [ ] [mrt-pixelformats](sapp/mrt-pixelformats-sapp.zig)
    // - [ ] [arraytex](sapp/arraytex-sapp.zig)
    // - [ ] [tex3d](sapp/tex3d-sapp.zig)
    // - [ ] [dyntex3d](sapp/dyntex3d-sapp.zig)
    // - [ ] [dyntex](sapp/dyntex-sapp.zig)
    // - [ ] [basisu](sapp/basisu-sapp.zig)
    // - [ ] [cubemap-jpeg](sapp/cubemap-jpeg-sapp.zig)
    // - [ ] [cubemaprt](sapp/cubemaprt-sapp.zig)
    // - [ ] [miprender](sapp/miprender-sapp.zig)
    // - [ ] [layerrender](sapp/layerrender-sapp.zig)
    // - [ ] [primtypes](sapp/primtypes-sapp.zig)
    // - [ ] [uvwrap](sapp/uvwrap-sapp.zig)
    // - [ ] [mipmap](sapp/mipmap-sapp.zig)
    // - [ ] [uniformtypes](sapp/uniformtypes-sapp.zig)
    // - [ ] [blend](sapp/blend-sapp.zig)
    // - [ ] [sdf](sapp/sdf-sapp.zig)
    // - [ ] [shadows](sapp/shadows-sapp.zig)
    // - [ ] [shadows-depthtex](sapp/shadows-depthtex-sapp.zig)
    // - [ ] [imgui](sapp/imgui-sapp.zig)
    // - [ ] [imgui-dock](sapp/imgui-dock-sapp.zig)
    // - [ ] [imgui-highdpi](sapp/imgui-highdpi-sapp.zig)
    // - [ ] [cimgui](sapp/cimgui-sapp.zig)
    // - [ ] [imgui-images](sapp/imgui-images-sapp.zig)
    // - [ ] [imgui-usercallback](sapp/imgui-usercallback-sapp.zig)
    // - [ ] [nuklear](sapp/nuklear-sapp.zig)
    // - [ ] [nuklear-images](sapp/nuklear-images-sapp.zig)
    // - [ ] [sgl-microui](sapp/sgl-microui-sapp.zig)
    // - [ ] [fontstash](sapp/fontstash-sapp.zig)
    // - [ ] [fontstash-layers](sapp/fontstash-layers-sapp.zig)
    // - [ ] [debugtext](sapp/debugtext-sapp.zig)
    // - [ ] [debugtext-printf](sapp/debugtext-printf-sapp.zig)
    // - [ ] [debugtext-userfont](sapp/debugtext-userfont-sapp.zig)
    // - [ ] [debugtext-context](sapp/debugtext-context-sapp.zig)
    // - [ ] [debugtext-layers](sapp/debugtext-layers-sapp.zig)
    // - [ ] [events](sapp/events-sapp.zig)
    // - [ ] [icon](sapp/icon-sapp.zig)
    // - [ ] [droptest](sapp/droptest-sapp.zig)
    // - [ ] [pixelformats](sapp/pixelformats-sapp.zig)
    // - [ ] [drawcallperf](sapp/drawcallperf-sapp.zig)
    // - [ ] [saudio](sapp/saudio-sapp.zig)
    // - [ ] [modplay](sapp/modplay-sapp.zig)
    // - [ ] [noentry](sapp/noentry-sapp.zig)
    // - [ ] [restart](sapp/restart-sapp.zig)
    // - [ ] [sgl](sapp/sgl-sapp.zig)
    .{
        .name = "sgl-lines",
        .root_source = "sapp/sgl-lines-sapp.zig",
    },
    // - [ ] [sgl-points](sapp/sgl-points-sapp.zig)
    // - [ ] [sgl-context](sapp/sgl-context-sapp.zig)
    // - [ ] [loadpng](sapp/loadpng-sapp.zig)
    // - [ ] [plmpeg](sapp/plmpeg-sapp.zig)
    // - [ ] [cgltf](sapp/cgltf-sapp.zig)
    .{
        .name = "ozz-anim",
        .root_source = "sapp/ozz-anim-sapp.zig",
        .sidemodule = true,
        .assets = &.{
            "sapp/data/ozz/ozz_anim_skeleton.ozz",
            "sapp/data/ozz/ozz_anim_animation.ozz",
        },
    },
    .{
        .name = "ozz-skin",
        .root_source = "sapp/ozz-skin-sapp.zig",
        .sidemodule = true,
        .shader = "sapp/ozz-skin-sapp.glsl",
    },
    // - [ ] [ozz-storagebuffer](sapp/ozz-storagebuffer-sapp.zig)
    // - [ ] [shdfeatures](sapp/shdfeatures-sapp.zig)
    // - [ ] [spine-simple](sapp/spine-simple-sapp.zig)
    // - [ ] [spine-inspector](sapp/spine-inspector-sapp.zig)
    // - [ ] [spine-layers](sapp/spine-layers-sapp.zig)
    // - [ ] [spine-skinsets](sapp/spine-skinsets-sapp.zig)
    // - [ ] [spine-switch-skinsets](sapp/spine-switch-skinsets-sapp.zig)
};

pub const all_examples = learnopengl_examples ++ sokol_examples;
