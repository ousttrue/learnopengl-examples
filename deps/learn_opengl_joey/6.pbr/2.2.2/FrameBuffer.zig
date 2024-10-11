const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("equirectangular_to_cubemap.glsl.zig");
const rowmath = @import("rowmath");
const Mat4 = rowmath.Mat4;
const Vec3 = rowmath.Vec3;
const FloatTexture = @import("FloatTexture.zig");
const FrameBuffer = @This();
image: sg.Image,
sampler: sg.Sampler,
attachments: [6]sg.Attachments,
vbo: sg.Buffer,
pip: sg.Pipeline,

const captureProjection = Mat4.makePerspective(
    std.math.degreesToRadians(90.0),
    1.0,
    0.1,
    10.0,
);
const captureViews = [_]Mat4{
    Mat4.makeLookAt(Vec3.zero, Vec3.right, Vec3.down),
    Mat4.makeLookAt(Vec3.zero, Vec3.left, Vec3.down),
    Mat4.makeLookAt(Vec3.zero, Vec3.up, Vec3.forward),
    Mat4.makeLookAt(Vec3.zero, Vec3.down, Vec3.backward),
    Mat4.makeLookAt(Vec3.zero, Vec3.forward, Vec3.down),
    Mat4.makeLookAt(Vec3.zero, Vec3.backward, Vec3.down)
};

pub fn initCubemap(size: i32) @This() {
    // framebuffer configuration
    // -------------------------
    // setup a render pass struct with one color and one depth render attachment image
    // NOTE: we need to explicitly set the sample count in the attachment image objects,
    // because the offscreen pass uses a different sample count than the display render pass
    // (the display render pass is multi-sampled, the offscreen pass is not)
    // create a color attachment texture
    var img_desc = sg.ImageDesc{
        .type = .CUBE,
        .render_target = true,
        .width = size,
        .height = size,
        .pixel_format = .RGBA16F,
        .sample_count = 1,
        .label = "color-image",
    };
    const color_img = sg.makeImage(img_desc);
    img_desc.pixel_format = .DEPTH;
    img_desc.label = "depth-image";
    // create a renderbuffer object for depth and stencil attachment (we won't be sampling these)
    const depth_img = sg.makeImage(img_desc);
    var attachments_desc = sg.AttachmentsDesc{
        .depth_stencil = .{
            .image = depth_img,
        },
        .label = "offscreen-attachments",
    };
    attachments_desc.colors[0].image = color_img;
    var attachments: [6]sg.Attachments = undefined;
    for (0..6) |i| {
        attachments_desc.colors[0].slice = @intCast(i);
        attachments[i] = sg.makeAttachments(attachments_desc);
    }

    const vertices = [_]f32{
        // back ace
        -1.0, -1.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, // bottom-let
        1.0, 1.0, -1.0, 0.0, 0.0, -1.0, 1.0, 1.0, // top-right
        1.0, -1.0, -1.0, 0.0, 0.0, -1.0, 1.0, 0.0, // bottom-right
        1.0, 1.0, -1.0, 0.0, 0.0, -1.0, 1.0, 1.0, // top-right
        -1.0, -1.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, // bottom-let
        -1.0, 1.0, -1.0, 0.0, 0.0, -1.0, 0.0, 1.0, // top-let
        // ront ace
        -1.0, -1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom-let
        1.0, -1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, // bottom-right
        1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, // top-right
        1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, // top-right
        -1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, // top-let
        -1.0, -1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom-let
        // let ace
        -1.0, 1.0, 1.0, -1.0, 0.0, 0.0, 1.0, 0.0, // top-right
        -1.0, 1.0, -1.0, -1.0, 0.0, 0.0, 1.0, 1.0, // top-let
        -1.0, -1.0, -1.0, -1.0, 0.0, 0.0, 0.0, 1.0, // bottom-let
        -1.0, -1.0, -1.0, -1.0, 0.0, 0.0, 0.0, 1.0, // bottom-let
        -1.0, -1.0, 1.0, -1.0, 0.0, 0.0, 0.0, 0.0, // bottom-right
        -1.0, 1.0, 1.0, -1.0, 0.0, 0.0, 1.0, 0.0, // top-right
        // right ace
        1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, // top-let
        1.0, -1.0, -1.0, 1.0, 0.0, 0.0, 0.0, 1.0, // bottom-right
        1.0, 1.0, -1.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top-right
        1.0, -1.0, -1.0, 1.0, 0.0, 0.0, 0.0, 1.0, // bottom-right
        1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, // top-let
        1.0, -1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, // bottom-let
        // bottom ace
        -1.0, -1.0, -1.0, 0.0, -1.0, 0.0, 0.0, 1.0, // top-right
        1.0, -1.0, -1.0, 0.0, -1.0, 0.0, 1.0, 1.0, // top-let
        1.0, -1.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0, // bottom-let
        1.0, -1.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0, // bottom-let
        -1.0, -1.0, 1.0, 0.0, -1.0, 0.0, 0.0, 0.0, // bottom-right
        -1.0, -1.0, -1.0, 0.0, -1.0, 0.0, 0.0, 1.0, // top-right
        // top ace
        -1.0, 1.0, -1.0, 0.0, 1.0, 0.0, 0.0, 1.0, // top-let
        1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom-right
        1.0, 1.0, -1.0, 0.0, 1.0, 0.0, 1.0, 1.0, // top-right
        1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom-right
        -1.0, 1.0, -1.0, 0.0, 1.0, 0.0, 0.0, 1.0, // top-let
        -1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, // bottom-let
    };
    const vbo = sg.makeBuffer(.{
        .data = sg.asRange(&vertices),
        .label = "cubemap",
    });

    var pip_desc = sg.PipelineDesc{
        .label = "to_cubemap",
        .shader = sg.makeShader(shader.equirectangularToCubemapShaderDesc(
            sg.queryBackend(),
        )),
        .depth = .{
            .write_enabled = true,
            .compare = .LESS,
            .pixel_format = .DEPTH,
        },
    };
    pip_desc.colors[0].pixel_format = .RGBA16F;
    pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
    const pip = sg.makePipeline(pip_desc);

    return .{
        .image = color_img,
        .sampler = sg.makeSampler(.{
            .mipmap_filter = .LINEAR,
            .min_filter = .LINEAR,
            .mag_filter = .LINEAR,
            .wrap_u = .CLAMP_TO_EDGE,
            .wrap_v = .CLAMP_TO_EDGE,
            .wrap_w = .CLAMP_TO_EDGE,
        }),
        .attachments = attachments,
        .vbo = vbo,
        .pip = pip,
    };
}

pub fn render(self: @This(), texture: FloatTexture) void {
    // glViewport(0, 0, 512, 512); // don't forget to configure the viewport to the capture dimensions.

    var bind = sg.Bindings{};
    bind.vertex_buffers[0] = self.vbo;
    bind.fs.images[shader.SLOT_equirectangularMap] = texture.image;
    bind.fs.samplers[shader.SLOT_equirectangularMapSampler] = texture.sampler;
    for (0..6) |i| {
        const pass_action = sg.PassAction{
            .colors = .{
                .{
                    .load_action = .CLEAR,
                    .clear_value = .{ .r = 0.1, .g = 0.1, .b = 0.1, .a = 1.0 },
                },
                .{},
                .{},
                .{},
            },
        };
        sg.beginPass(.{
            .action = pass_action,
            .attachments = self.attachments[i],
        });
        defer sg.endPass();

        {
            sg.applyPipeline(self.pip);
            sg.applyBindings(bind);
            const vs_params = shader.VsParams{
                .projection = captureProjection.m,
                .view = captureViews[i].m,
            };
            sg.applyUniforms(
                .VS,
                shader.SLOT_vs_params,
                sg.asRange(&vs_params),
            );
            sg.draw(0, 36, 1);
        }
    }

    // then let OpenGL generate mipmaps from first mip face (combatting visible dots artifact)
    // glBindTexture(GL_TEXTURE_CUBE_MAP, envCubemap);
    // glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
}
