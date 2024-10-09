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
    .{
        .name = "hello_triangle",
        .root_source = _1 ++ "2.1/hello_triangle.zig",
        .shaders = &.{_1 ++ "2.1/hello_triangle.glsl"},
    },
    .{
        .name = "colors",
        .root_source = _2 ++ "1.1/colors.zig",
        .shaders = &.{
            _2 ++ "1.1/colors.glsl",
            _2 ++ "1.1/light_cube.glsl",
        },
    },
    .{
        .name = "ibl_specular_textured",
        .root_source = _6 ++ "2.2.2/ibl_specular_textured.zig",
        .shaders = &.{},
    },
};
