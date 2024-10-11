const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("irradiance_convolution.glsl.zig");
const EnvCubemap = @import("EnvCubemap.zig");
pub const IrradianceMap = @This();

image: sg.Image,
sampler: sg.Sampler,
attachments: [6]sg.Attachments,

// pbr: create an irradiance cubemap, and re-scale capture FBO to irradiance scale.
pub fn init() @This() {
    const size = 32;
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

    return .{
        .image = color_img,
        .sampler = sg.makeSampler(.{
            // glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            // glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            // glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
            // glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            // glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        }),
        .attachments = attachments,
    };
}

// pbr: solve diffuse integral by convolution to create an irradiance (cube)map.
pub fn render(self: @This(), envCubemap: EnvCubemap) void {
    // glViewport(0, 0, 32, 32); // don't forget to configure the viewport to the capture dimensions.
    var pip_desc = sg.PipelineDesc{
        .label = "irradiance_convolution",
        .shader = sg.makeShader(shader.irradianceConvolutionShaderDesc(
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

    var bind = sg.Bindings{};
    bind.vertex_buffers[0] = envCubemap.vbo;
    bind.fs.images[shader.SLOT_environmentMap] = envCubemap.image;
    bind.fs.samplers[shader.SLOT_environmentMapSampler] = envCubemap.sampler;
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
            sg.applyPipeline(pip);
            sg.applyBindings(bind);
            const vs_params = shader.VsParams{
                .projection = EnvCubemap.captureProjection.m,
                .view = EnvCubemap.captureViews[i].m,
            };
            sg.applyUniforms(
                .VS,
                shader.SLOT_vs_params,
                sg.asRange(&vs_params),
            );
            sg.draw(0, 36, 1);
        }
    }
}
