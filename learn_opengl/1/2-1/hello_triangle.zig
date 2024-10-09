// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.1.hello_triangle/hello_triangle.cpp
// https://github.com/floooh/sokol-zig/blob/master/src/examples/triangle.zig
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("hello_triangle.glsl.zig");

// settings
const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;
const TITLE = "1-2-1 hello_triangle";

// application state
const state = struct {
    var pip = sg.Pipeline{};
    var bind = sg.Bindings{};
};

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    const vertices = [_]f32{
        -0.5, -0.5, 0.0, // let
        0.5, -0.5, 0.0, // right
        0.0, 0.5, 0.0, // top
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&vertices),
        .label = "vertices",
    });

    const shd = sg.makeShader(shader.helloTriangleShaderDesc(sg.queryBackend()));

    var pip_desc = sg.PipelineDesc{
        .shader = shd,
        .label = "hello_triangle",
    };
    pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
    state.pip = sg.makePipeline(pip_desc);
}

export fn frame() void {
    const pass_action = sg.PassAction{
        .colors = .{
            .{
                .load_action = .CLEAR,
                .clear_value = .{ .r = 0.2, .g = 0.3, .b = 0.3, .a = 1.0 },
            },
            .{},
            .{},
            .{},
        },
    };
    sg.beginPass(.{
        .action = pass_action,
        .swapchain = sokol.glue.swapchain(),
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

pub fn main() void {
    sokol.app.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = SCR_WIDTH,
        .height = SCR_HEIGHT,
        .high_dpi = true,
        .window_title = TITLE,
    });
}
