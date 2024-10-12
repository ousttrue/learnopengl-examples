const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("brdf.glsl.zig");
const size = 512;

image: sg.Image,
sampler: sg.Sampler,

const quadVertices = [_]f32{
    // positions        // texture Coords
    -1.0, 1.0,  0.0, 0.0, 1.0,
    -1.0, -1.0, 0.0, 0.0, 0.0,
    1.0,  1.0,  0.0, 1.0, 1.0,
    1.0,  -1.0, 0.0, 1.0, 0.0,
};

pub fn init() @This() {
    return .{
        .image = sg.makeImage(.{
            .type = .CUBE,
            .render_target = true,
            .width = size,
            .height = size,
            .pixel_format = .RGBA16F,
            .sample_count = 1,
            .label = "color-image",
        }),
        .sampler = sg.makeSampler(.{
            .mipmap_filter = .LINEAR,
            .min_filter = .LINEAR,
            .mag_filter = .LINEAR,
            .wrap_u = .CLAMP_TO_EDGE,
            .wrap_v = .CLAMP_TO_EDGE,
        }),
    };
}

pub fn render(self: @This()) void {
    const depth_img = sg.makeImage(.{
        .type = .CUBE,
        .render_target = true,
        .width = size,
        .height = size,
        .pixel_format = .DEPTH,
        .sample_count = 1,
        .label = "depth-image",
    });
    defer sg.destroyImage(depth_img);

    var attachments_desc = sg.AttachmentsDesc{
        .depth_stencil = .{
            .image = depth_img,
        },
        .label = "offscreen-attachments",
    };
    attachments_desc.colors[0].image = self.image;
    const attachments = sg.makeAttachments(attachments_desc);
    defer sg.destroyAttachments(attachments);

    const vbo = sg.makeBuffer(.{
        .data = sg.asRange(&quadVertices),
        .label = "quad",
    });
    defer sg.destroyBuffer(vbo);

    var pip_desc = sg.PipelineDesc{
        .label = "lut",
        .shader = sg.makeShader(shader.brdfShaderDesc(
            sg.queryBackend(),
        )),
        .depth = .{
            .write_enabled = true,
            .compare = .LESS,
            .pixel_format = .DEPTH,
        },
        .primitive_type = .TRIANGLE_STRIP,
    };
    pip_desc.colors[0].pixel_format = .RGBA16F;
    pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_aTexCoords].format = .FLOAT2;
    const pip = sg.makePipeline(pip_desc);
    defer sg.destroyPipeline(pip);

    var bind = sg.Bindings{};
    bind.vertex_buffers[0] = vbo;
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
        .attachments = attachments,
    });
    defer sg.endPass();
    sg.applyViewport(0, 0, size, size, false);

    sg.applyPipeline(pip);
    sg.applyBindings(bind);
    sg.draw(0, 4, 1);
}

