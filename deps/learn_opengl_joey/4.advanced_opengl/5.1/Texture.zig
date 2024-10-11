const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const stb_image = @import("stb_image");

pub const Texture = @This();

image: sg.Image,
sampler: sg.Sampler,

pub fn init(width: i32, height: i32, pixels: [*]const u8) @This() {
    const texture = Texture{
        .image = sg.allocImage(),
        .sampler = sg.allocSampler(),
    };

    // initialize the sokol-gfx texture
    var img_desc = sg.ImageDesc{
        .width = width,
        .height = height,
        // set pixel_format to RGBA8 for WebGL
        .pixel_format = .RGBA8,
    };
    img_desc.data.subimage[0][0] = .{
        .ptr = pixels,
        .size = @intCast(width * height * 4),
    };
    sg.initImage(texture.image, img_desc);

    sg.initSampler(texture.sampler, .{
        .wrap_u = .REPEAT,
        .wrap_v = .REPEAT,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .compare = .NEVER,
    });
    return texture;
}

pub fn load(ptr: ?*const anyopaque, size: usize) !@This() {
    var img_width: c_int = undefined;
    var img_height: c_int = undefined;
    var num_channels: c_int = undefined;
    const desired_channels = 4;
    const pixels = stb_image.stbi_load_from_memory(
        @ptrCast(ptr),
        @intCast(size),
        &img_width,
        &img_height,
        &num_channels,
        desired_channels,
    );
    if (pixels != null) {
        defer stb_image.stbi_image_free(pixels);
        std.debug.print(
            "{} x {}: {}ch\n",
            .{ img_width, img_height, num_channels },
        );
        return Texture.init(
            img_width,
            img_height,
            pixels,
        );
    } else {
        return error.stbi_load;
    }
}
