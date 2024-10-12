const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("equirectangular_to_cubemap.glsl.zig");
const rowmath = @import("rowmath");
const Mat4 = rowmath.Mat4;
const Vec3 = rowmath.Vec3;
const FloatTexture = @import("FloatTexture.zig");
pub const EnvCubemap = @This();

image: sg.Image,
sampler: sg.Sampler,
vbo: sg.Buffer,

pub const captureProjection = Mat4.makePerspective(
    std.math.degreesToRadians(90.0),
    1.0,
    0.1,
    10.0,
);
pub const captureViews = [_]Mat4{
    Mat4.makeLookAt(Vec3.zero, Vec3.right, Vec3.down),
    Mat4.makeLookAt(Vec3.zero, Vec3.left, Vec3.down),
    Mat4.makeLookAt(Vec3.zero, Vec3.up, Vec3.forward),
    Mat4.makeLookAt(Vec3.zero, Vec3.down, Vec3.backward),
    Mat4.makeLookAt(Vec3.zero, Vec3.forward, Vec3.down),
    Mat4.makeLookAt(Vec3.zero, Vec3.backward, Vec3.down),
};
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
const size = 512;

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
            .wrap_w = .CLAMP_TO_EDGE,
        }),
        .vbo = sg.makeBuffer(.{
            .data = sg.asRange(&vertices),
            .label = "cubemap",
        }),
    };
}

pub fn render(self: @This(), texture: FloatTexture) void {
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
    defer sg.destroyPipeline(pip);

    self.renderCube(
        size,
        texture.image,
        texture.sampler,
        self.image,
        pip,
        shader,
        .{},
    );
}

pub fn renderCube(
    self: @This(),
    viewport_size: i32,
    src_image: sg.Image,
    src_sampler: sg.Sampler,
    dst_image: sg.Image,
    pip: sg.Pipeline,
    SHADER: type,
    opts: anytype,
) void {
    const depth_img = sg.makeImage(.{
        .type = .CUBE,
        .render_target = true,
        .width = viewport_size,
        .height = viewport_size,
        .pixel_format = .DEPTH,
        .sample_count = 1,
        .label = "depth-image",
    });
    defer sg.destroyImage(depth_img);
    for (0..6) |i| {
        var attachments_desc = sg.AttachmentsDesc{
            .depth_stencil = .{
                .image = depth_img,
            },
            .label = "offscreen-attachments",
        };
        attachments_desc.colors[0].slice = @intCast(i);
        attachments_desc.colors[0].image = dst_image;
        if (@hasField(@TypeOf(opts), "mip_level")) {
            attachments_desc.colors[0].mip_level = opts.mip_level;
        }
        const attachments = sg.makeAttachments(attachments_desc);
        defer sg.destroyAttachments(attachments);

        var bind = sg.Bindings{};
        bind.vertex_buffers[0] = self.vbo;
        bind.fs.images[shader.SLOT_equirectangularMap] = src_image;
        bind.fs.samplers[shader.SLOT_equirectangularMapSampler] = src_sampler;
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
        sg.applyViewport(0, 0, viewport_size, viewport_size, false);

        {
            sg.applyPipeline(pip);
            sg.applyBindings(bind);
            const vs_params = SHADER.VsParams{
                .projection = captureProjection.m,
                .view = captureViews[i].m,
            };
            sg.applyUniforms(
                .VS,
                shader.SLOT_vs_params,
                sg.asRange(&vs_params),
            );
            if (@hasField(@TypeOf(opts), "roughness")) {
                const fs_params = SHADER.FsParams{
                    .roughness = opts.roughness,
                };
                sg.applyUniforms(
                    .FS,
                    SHADER.SLOT_fs_params,
                    sg.asRange(&fs_params),
                );
            }
            sg.draw(0, 36, 1);
        }
    }
}
