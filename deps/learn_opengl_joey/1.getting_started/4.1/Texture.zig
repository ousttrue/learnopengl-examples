const sokol = @import("sokol");
const sg = sokol.gfx;

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
