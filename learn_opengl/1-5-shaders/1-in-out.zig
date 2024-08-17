//------------------------------------------------------------------------------
//  1-5-1-in-out
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const sapp = sokol.app;
const sg = sokol.gfx;
const sglue = sokol.glue;
const shader = @import("1-in-out.glsl.zig");

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

    // a vertex buffer with 3 vertices
    const vertices = [_]f32{
        // positions
        -0.5, -0.5, 0.0, // bottom let
        0.5, -0.5, 0.0, // bottom right
        0.0, 0.5, 0.0, // top
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .data = sg.asRange(&vertices),
        .label = "triangle-vertices",
    });

    // create a pipeline object (default render states are fine for triangle)
    var pip_desc = sg.PipelineDesc{
        .shader = shd,
        // if the vertex layout doesn't have gaps, don't need to provide strides and offsets
        .label = "triangle-pipeline",
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
    sg.draw(0, 3, 1);
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
        .window_title = "In Out - LearnOpenGL",
    });
}
