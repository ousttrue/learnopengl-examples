const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const EnvCubemap = @import("EnvCubemap.zig");
const shader = @import("prefilter.glsl.zig");
pub const PrefilterMap = @This();
const maxMipLevels = 5;
const size = 128;

image: sg.Image,
sampler: sg.Sampler,

// pbr: create a pre-filter cubemap, and re-scale capture FBO to pre-filter scale.
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
            .num_mipmaps = maxMipLevels,
        }),
        .sampler = sg.makeSampler(.{
            .wrap_u = .CLAMP_TO_EDGE,
            .wrap_v = .CLAMP_TO_EDGE,
            .wrap_w = .CLAMP_TO_EDGE,
            .mipmap_filter = .LINEAR,
            .min_filter = .LINEAR,
            .mag_filter = .LINEAR,
        }),
    };
}

// pbr: run a quasi monte-carlo simulation on the environment lighting to create a prefilter (cube)map.
pub fn render(self: @This(), env_cubemap: EnvCubemap) void {
    var pip_desc = sg.PipelineDesc{
        .label = "irradiance_convolution",
        .shader = sg.makeShader(shader.prefilterShaderDesc(
            sg.queryBackend(),
        )),
        .depth = .{
            .write_enabled = true,
            .compare = .LESS,
            .pixel_format = .DEPTH,
        },
    };
    pip_desc.colors[0].pixel_format = .RGBA16F;
    pip_desc.layout.buffers[0].stride = 4 * 8;
    pip_desc.layout.attrs[shader.ATTR_prefilter_aPos].format = .FLOAT3;
    const pip = sg.makePipeline(pip_desc);
    defer sg.destroyPipeline(pip);

    for (0..maxMipLevels) |mip_level| {
        // attachments_desc.colors[0].mip_level = @intCast(mip);
        // reisze framebuffer according to mip-level size.
        const mip_size: i32 = @intFromFloat(size * std.math.pow(
            f32,
            0.5,
            @floatFromInt(mip_level),
        ));
        const roughness = @as(f32, @floatFromInt(mip_level)) / @as(f32, @floatFromInt(maxMipLevels - 1));
        env_cubemap.renderCube(
            mip_size,
            .{ .image = env_cubemap.image, .sampler = env_cubemap.sampler },
            self.image,
            pip,
            shader,
            .{ .mip_level = @as(i32, @intCast(mip_level)), .roughness = roughness },
        );
    }
}
