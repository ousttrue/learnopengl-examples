pub const Example = struct {
    name: []const u8,
    root_source: []const u8,
    shaders: []const []const u8,
};

const _1 = "1.getting_started/";
const _2 = "2.lighting/";
const _3 = "3.model_loading/";
const _4 = "4.advanced_opengl/";
const _5 = "5.advanced_lighting/";
const _6 = "6.pbr/";

pub const examples = [_]Example{
    // 1.getting_started
    .{
        .name = "hello_triangle",
        .root_source = _1 ++ "2.1/hello_triangle.zig",
        .shaders = &.{_1 ++ "2.1/hello_triangle.glsl"},
    },
    .{
        .name = "textures",
        .root_source = _1 ++ "4.1/textures.zig",
        .shaders = &.{_1 ++ "4.1/textures.glsl"},
    },
    // 2.light_cube
    .{
        .name = "colors",
        .root_source = _2 ++ "1.1/colors.zig",
        .shaders = &.{
            _2 ++ "1.1/colors.glsl",
            _2 ++ "1.1/light_cube.glsl",
        },
    },
    // 4.advanced_opengl
    .{
        .name = "framebuffers",
        .root_source = _4 ++ "5.1/framebuffers.zig",
        .shaders = &.{
            _4 ++ "5.1/framebuffers.glsl",
            _4 ++ "5.1/screen.glsl",
        },
    },
    .{
        .name = "cubemap_skybox",
        .root_source = _4 ++ "6.1/cubemap_skybox.zig",
        .shaders = &.{
            _4 ++ "6.1/cubemap.glsl",
            _4 ++ "6.1/skybox.glsl",
        },
    },
    // 6.pbr
    .{
        .name = "hdr_cubemap",
        .root_source = _6 ++ "2.2.2/hdr_cubemap.zig",
        .shaders = &.{
            _6 ++ "2.2.2/equirectangular_to_cubemap.glsl",
            _6 ++ "2.2.2/background.glsl",
            _6 ++ "2.2.2/quad.glsl",
        },
    },
    .{
        .name = "ibl_specular_textured",
        .root_source = _6 ++ "2.2.2/ibl_specular_textured.zig",
        .shaders = &.{
            _6 ++ "2.2.2/pbr.glsl",
            _6 ++ "2.2.2/equirectangular_to_cubemap.glsl",
            _6 ++ "2.2.2/irradiance_convolution.glsl",
            _6 ++ "2.2.2/prefilter.glsl",
            _6 ++ "2.2.2/brdf.glsl",
            _6 ++ "2.2.2/background.glsl",
        },
    },
};
