pub const Example = struct {
    name: []const u8,
    root_source: []const u8,
    shaders: []const []const u8,
};

pub const examples = [_]Example{
    .{
        .name = "hello_triangle",
        .root_source = "1/2-1/hello_triangle.zig",
        .shaders = &.{"1/2-1/hello_triangle.glsl"},
    },
    .{
        .name = "colors",
        .root_source = "2/1-1/colors.zig",
        .shaders = &.{
            "2/1-1/colors.glsl",
            "2/1-1/light_cube.glsl",
        },
    },
};
