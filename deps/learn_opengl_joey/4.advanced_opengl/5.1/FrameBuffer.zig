const sokol = @import("sokol");
const sg = sokol.gfx;

const FrameBuffer = @This();
image: sg.Image,
sampler: sg.Sampler,
attachments: sg.Attachments,

pub fn init() @This() {
    // framebuffer configuration
    // -------------------------
    // setup a render pass struct with one color and one depth render attachment image
    // NOTE: we need to explicitly set the sample count in the attachment image objects,
    // because the offscreen pass uses a different sample count than the display render pass
    // (the display render pass is multi-sampled, the offscreen pass is not)
    // create a color attachment texture
    var img_desc = sg.ImageDesc{
        .render_target = true,
        .width = 256,
        .height = 256,
        .pixel_format = .RGBA8,
        .sample_count = 1,
        .label = "color-image",
    };
    const color_img = sg.makeImage(img_desc);
    img_desc.pixel_format = .DEPTH;
    img_desc.label = "depth-image";
    // create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
    const depth_img = sg.makeImage(img_desc);
    var attachments_desc = sg.AttachmentsDesc{
        .depth_stencil = .{ .image = depth_img },
        .label = "offscreen-attachments",
    };
    attachments_desc.colors[0].image = color_img;

    return .{
        .image = color_img,
        .sampler = sg.makeSampler(.{
            .min_filter = .LINEAR,
            .mag_filter = .LINEAR,
        }),
        .attachments = sg.makeAttachments(attachments_desc),
    };
}
