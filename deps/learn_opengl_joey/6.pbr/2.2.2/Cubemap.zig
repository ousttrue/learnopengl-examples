const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const Image = @import("Image.zig");
pub const Cubemap = @This();

image: sg.Image,
sampler: sg.Sampler,

pub fn create(size: i32) @This() {
    _ = size;
    unreachable;
    // pbr: setup cubemap to render to and attach to framebuffer
    // ---------------------------------------------------------
    //     unsigned int envCubemap;
    //     glGenTextures(1, &envCubemap);
    //     glBindTexture(GL_TEXTURE_CUBE_MAP, envCubemap);
    //     for (unsigned int i = 0; i < 6; ++i)
    //     {
    //         glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB16F, 512, 512, 0, GL_RGB, GL_FLOAT, nullptr);
    //     }
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); // enable pre-filter mipmap sampling (combatting visible dots artifact)
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

// loads a cubemap texture from 6 individual texture faces
// order:
// +X (right)
// -X (left)
// +Y (top)
// -Y (bottom)
// +Z (front)
// -Z (back)
pub fn init(images: []const Image) @This() {
    const width: i32 = @intCast(images[0].width);
    const height: i32 = @intCast(images[0].height);
    for (images[1..]) |image| {
        std.debug.assert(image.width == width);
        std.debug.assert(image.height == height);
    }

    const cubemap = Cubemap{
        .image = sg.allocImage(),
        .sampler = sg.makeSampler(.{
            .min_filter = .LINEAR,
            .mag_filter = .LINEAR,
            .label = "cubemap-sampler",
        }),
    };

    var image_desc = sg.ImageDesc{
        .type = .CUBE,
        .width = width,
        .height = height,
        .pixel_format = .RGBA8,
        .label = "cubemap-image",
    };
    image_desc.data.subimage[0][0] = sg.asRange(images[0].pixels);
    image_desc.data.subimage[1][0] = sg.asRange(images[1].pixels);
    image_desc.data.subimage[2][0] = sg.asRange(images[2].pixels);
    image_desc.data.subimage[3][0] = sg.asRange(images[3].pixels);
    image_desc.data.subimage[4][0] = sg.asRange(images[4].pixels);
    image_desc.data.subimage[5][0] = sg.asRange(images[5].pixels);
    sg.initImage(cubemap.image, image_desc);

    return cubemap;
}
