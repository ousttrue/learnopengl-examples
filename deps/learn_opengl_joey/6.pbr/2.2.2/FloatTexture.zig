const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const stb_image = @import("stb_image");
pub const FloatTexture = @This();

image: sg.Image,
sampler: sg.Sampler,

pub fn init(width: i32, height: i32, pixels: [*]const f32) @This() {
    const texture = FloatTexture{
        .image = sg.allocImage(),
        .sampler = sg.allocSampler(),
    };

    // initialize the sokol-gfx texture
    var img_desc = sg.ImageDesc{
        .width = width,
        .height = height,
        // set pixel_format to RGBA8 for WebGL
        .pixel_format = .RGBA32F,
    };
    img_desc.data.subimage[0][0] = .{
        .ptr = pixels,
        .size = @intCast(width * height * 4 * 4),
    };
    sg.initImage(texture.image, img_desc);

    sg.initSampler(texture.sampler, .{
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
    });
    return texture;
}

pub fn load(ptr: ?*const anyopaque, size: usize) !@This() {
    // pbr: load the HDR environment map
    // ---------------------------------
    // stb_image.stbi_set_flip_vertically_on_load(1);
    var width: c_int = undefined;
    var height: c_int = undefined;
    var nrComponents: c_int = undefined;
    const _pixels = stb_image.stbi_loadf_from_memory(
        @ptrCast(ptr),
        @intCast(size),
        &width,
        &height,
        &nrComponents,
        4,
    );
    const pixels = _pixels orelse {
        return error.stbi_loadf_from_memory;
    };
    defer stb_image.stbi_image_free(pixels);

    std.debug.print(
        "{} x {}: {}ch\n",
        .{ width, height, nrComponents },
    );
    return FloatTexture.init(
        width,
        height,
        pixels,
    );
}
