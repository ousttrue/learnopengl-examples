const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("quad.glsl.zig");
const rowmath = @import("rowmath");
const Mat4 = rowmath.Mat4;

const quadVertices = [_]f32{
    // positions        // texture Coords
    -1.0, 1.0,  0.0, 0.0, 1.0,
    -1.0, -1.0, 0.0, 0.0, 0.0,
    1.0,  1.0,  0.0, 1.0, 1.0,
    1.0,  -1.0, 0.0, 1.0, 0.0,
};

vbo: sg.Buffer,
pip: sg.Pipeline,

pub fn init() @This() {
    var pip_desc = sg.PipelineDesc{
        .label = "quad",
        .shader = sg.makeShader(shader.quadShaderDesc(
            sg.queryBackend(),
        )),
        .primitive_type = .TRIANGLE_STRIP,
    };
    pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_aTexCoords].format = .FLOAT2;

    return .{
        .vbo = sg.makeBuffer(.{
            .data = sg.asRange(&quadVertices),
            .label = "quad",
        }),
        .pip = sg.makePipeline(pip_desc),
    };
}

pub const DrawOpts = struct {
    image: sg.Image,
    sampler: sg.Sampler,
};

pub fn draw(self: @This(), opts: DrawOpts) void {
    sg.applyPipeline(self.pip);
    var bind = sg.Bindings{};
    bind.vertex_buffers[0] = self.vbo;
    bind.fs.images[shader.SLOT_texture1] = opts.image;
    bind.fs.samplers[shader.SLOT_texture1Sampler] = opts.sampler;
    sg.applyBindings(bind);
    sg.draw(0, 4, 1);
}
