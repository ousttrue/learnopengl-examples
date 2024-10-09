// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.1.hello_triangle/hello_triangle.cpp
// https://github.com/floooh/sokol-zig/blob/master/src/examples/triangle.zig
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("hello_triangle.glsl.zig");

// settings
const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;
const TITLE = "1.2.1 hello_triangle";

// application state
const state = struct {
    var pip = sg.Pipeline{};
    var vertex_buffer = sg.Buffer{};
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
    state.vertex_buffer = sg.makeBuffer(.{
        .data = sg.asRange(&vertices),
        .label = "vertices",
    });

    var pip_desc = sg.PipelineDesc{
        .shader = sg.makeShader(shader.helloTriangleShaderDesc(sg.queryBackend())),
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
    defer sg.commit();

    {
        sg.beginPass(.{
            .action = pass_action,
            .swapchain = sokol.glue.swapchain(),
        });
        defer sg.endPass();

        {
            sg.applyPipeline(state.pip);
            var bind = sg.Bindings{};
            bind.vertex_buffers[0] = state.vertex_buffer;
            sg.applyBindings(bind);
            sg.draw(0, 3, 1);
        }
    }
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
