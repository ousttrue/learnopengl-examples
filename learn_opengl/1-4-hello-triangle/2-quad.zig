//------------------------------------------------------------------------------
//  1-4-2-quad
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const shader = @import("2-quad.glsl.zig");

// application state
const state = struct {
    var pip = sg.Pipeline{};
    var bind = sg.Bindings{};
    var pass_action = sg.PassAction{};
};

export fn init() void {
    sg.setup(.{ .environment = sglue.environment() });

    // create shader from code-generated sg_shader_desc
    const shd = sg.makeShader(shader.simpleShaderDesc(sg.queryBackend()));

    // a vertex buffer with 4 vertices
    const vertices = [_]f32{
        // positions
        0.5, 0.5, 0.0, // top right
        0.5, -0.5, 0.0, // bottom right
        -0.5, -0.5, 0.0, // bottom let
        -0.5, 0.5, 0.0, // top let
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .data = sg.asRange(&vertices),
        .label = "quad-vertices",
    });

    // an index buffer with 2 triangles
    const indices = [_]u16{
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .size = @sizeOf(@TypeOf(indices)),
        .data = sg.asRange(&indices),
        .label = "quad-indices",
    });

    // a pipeline state object
    var pip_desc: sg.PipelineDesc = .{
        .shader = shd,
        .index_type = .UINT16,
        .label = "quad-pipeline",
    };
    pip_desc.layout.attrs[shader.ATTR_vs_position].format = .FLOAT3;
    state.pip = sg.makePipeline(pip_desc);

    // a pass action to clear framebuffer
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.2, .g = 0.3, .b = 0.3, .a = 1.0 },
    };
}

export fn frame() void {
    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sglue.swapchain(),
    });
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 6, 1);
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}

export fn event(e: [*c]const sapp.Event) void {
    if (e.*.type == .KEY_DOWN) {
        if (e.*.key_code == .ESCAPE) {
            sapp.requestQuit();
        }
    }
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 800,
        .height = 600,
        .high_dpi = true,
        .window_title = "Quad - LearnOpenGL",
    });
}
