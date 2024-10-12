const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("irradiance_convolution.glsl.zig");
const EnvCubemap = @import("EnvCubemap.zig");
pub const IrradianceMap = @This();

image: sg.Image,
sampler: sg.Sampler,

const size = 32;

// pbr: create an irradiance cubemap, and re-scale capture FBO to irradiance scale.
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
            .wrap_u = .CLAMP_TO_EDGE,
            .wrap_v = .CLAMP_TO_EDGE,
            .wrap_w = .CLAMP_TO_EDGE,
            .min_filter = .LINEAR,
            .mag_filter = .LINEAR,
        }),
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
    defer sg.destroyPipeline(pip);

    envCubemap.renderCube(
        size,
        .{ .image = envCubemap.image, .sampler = envCubemap.sampler },
        self.image,
        pip,
        shader,
        .{},
    );
}
