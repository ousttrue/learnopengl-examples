const std = @import("std");
const stb_image = @import("stb_image");
pub const Image = @This();

width: u32,
height: u32,
pixels: []const u8,

pub fn load(src: []const u8, dst: []u8) !@This() {
    var img_width: c_int = undefined;
    var img_height: c_int = undefined;
    var num_channels: c_int = undefined;
    const desired_channels = 4;
    const pixels = stb_image.stbi_load_from_memory(
        &src[0],
        @intCast(src.len),
        &img_width,
        &img_height,
        &num_channels,
        desired_channels,
    );
    if (pixels != null) {
        defer stb_image.stbi_image_free(pixels);
        const p: [*]const u8 = @ptrCast(pixels);
        std.mem.copyForwards(u8, dst, p[0..@intCast(img_width * img_height * 4)]);
        return .{
            .width = @intCast(img_width),
            .height = @intCast(img_height),
            .pixels = dst,
        };
    } else {
        return error.stbi_load;
    }
}
