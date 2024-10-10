// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/2.lighting/1.colors/colors.cpp
const sokol = @import("sokol");
const sg = sokol.gfx;
const colors_shader = @import("colors.glsl.zig");
const light_cube_shader = @import("light_cube.glsl.zig");
const rowmath = @import("rowmath");
const InputState = rowmath.InputState;
const OrbitCamera = rowmath.OrbitCamera;
const Mat4 = rowmath.Mat4;
const Vec3 = rowmath.Vec3;

// settings
const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;
const TITLE = "2.1.1 colors";

const state = struct {
    var lighting_pip = sg.Pipeline{};
    var light_cube_pip = sg.Pipeline{};
    var vertex_buffer = sg.Buffer{};

    var input = InputState{};
    var orbit = OrbitCamera{};

    var lightPos = Vec3{ .x = 1.2, .y = 1.0, .z = 2.0 };
};

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });
    sokol.time.setup();

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    const vertices = [_]f32{
        -0.5, -0.5, -0.5,
        0.5,  -0.5, -0.5,
        0.5,  0.5,  -0.5,
        0.5,  0.5,  -0.5,
        -0.5, 0.5,  -0.5,
        -0.5, -0.5, -0.5,

        -0.5, -0.5, 0.5,
        0.5,  -0.5, 0.5,
        0.5,  0.5,  0.5,
        0.5,  0.5,  0.5,
        -0.5, 0.5,  0.5,
        -0.5, -0.5, 0.5,

        -0.5, 0.5,  0.5,
        -0.5, 0.5,  -0.5,
        -0.5, -0.5, -0.5,
        -0.5, -0.5, -0.5,
        -0.5, -0.5, 0.5,
        -0.5, 0.5,  0.5,

        0.5,  0.5,  0.5,
        0.5,  0.5,  -0.5,
        0.5,  -0.5, -0.5,
        0.5,  -0.5, -0.5,
        0.5,  -0.5, 0.5,
        0.5,  0.5,  0.5,

        -0.5, -0.5, -0.5,
        0.5,  -0.5, -0.5,
        0.5,  -0.5, 0.5,
        0.5,  -0.5, 0.5,
        -0.5, -0.5, 0.5,
        -0.5, -0.5, -0.5,

        -0.5, 0.5,  -0.5,
        0.5,  0.5,  -0.5,
        0.5,  0.5,  0.5,
        0.5,  0.5,  0.5,
        -0.5, 0.5,  0.5,
        -0.5, 0.5,  -0.5,
    };
    state.vertex_buffer = sg.makeBuffer(.{
        .data = sg.asRange(&vertices),
        .label = "vertices",
    });

    {
        var pip_desc = sg.PipelineDesc{
            .label = "lighting",
            .shader = sg.makeShader(colors_shader.colorsShaderDesc(
                sg.queryBackend(),
            )),
            .depth = .{
                .write_enabled = true,
                .compare = .LESS_EQUAL,
            },
        };
        pip_desc.layout.attrs[colors_shader.ATTR_vs_aPos].format = .FLOAT3;
        state.lighting_pip = sg.makePipeline(pip_desc);
    }
    {
        var pip_desc = sg.PipelineDesc{
            .label = "light_cube",
            .shader = sg.makeShader(light_cube_shader.lightCubeShaderDesc(
                sg.queryBackend(),
            )),
            .depth = .{
                .write_enabled = true,
                .compare = .LESS_EQUAL,
            },
        };
        pip_desc.layout.attrs[colors_shader.ATTR_vs_aPos].format = .FLOAT3;
        state.light_cube_pip = sg.makePipeline(pip_desc);
    }
}

export fn frame() void {
    state.input.screen_width = sokol.app.widthf();
    state.input.screen_height = sokol.app.heightf();
    state.orbit.frame(state.input);
    state.input.mouse_wheel = 0;

    defer sg.commit();
    {
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
            .swapchain = sokol.glue.swapchain(),
        });
        defer sg.endPass();

        var bind = sg.Bindings{};
        bind.vertex_buffers[0] = state.vertex_buffer;

        {
            // be sure to activate shader when setting uniforms/drawing objects
            sg.applyPipeline(state.lighting_pip);
            sg.applyBindings(bind);

            // view/projection transformations
            const projection = state.orbit.projectionMatrix();
            const view = state.orbit.viewMatrix();
            const vs_params = colors_shader.VsParams{
                .model = Mat4.identity.m,
                .view = view.m,
                .projection = projection.m,
            };
            sg.applyUniforms(.VS, colors_shader.SLOT_vs_params, sg.asRange(&vs_params));

            const fs_params = colors_shader.FsParams{
                .objectColor = .{ 1.0, 0.5, 0.31 },
                .lightColor = .{ 1.0, 1.0, 1.0 },
            };
            sg.applyUniforms(.FS, colors_shader.SLOT_fs_params, sg.asRange(&fs_params));

            // render the cube
            sg.draw(0, 36, 1);
        }

        {
            // also draw the lamp object
            sg.applyPipeline(state.light_cube_pip);
            sg.applyBindings(bind);

            const projection = state.orbit.projectionMatrix();
            const view = state.orbit.viewMatrix();
            const t = Mat4.makeTranslation(state.lightPos);
            const s = Mat4.makeScale(.{ .x = 0.2, .y = 0.2, .z = 0.3 }); // a smaller cube
            const m = s.mul(t);
            const vs_params = light_cube_shader.VsParams{
                .model = m.m,
                .view = view.m,
                .projection = projection.m,
            };
            sg.applyUniforms(.VS, light_cube_shader.SLOT_vs_params, sg.asRange(&vs_params));

            sg.draw(0, 36, 1);
        }
    }
}

export fn event(e: [*c]const sokol.app.Event) void {
    switch (e.*.type) {
        .MOUSE_DOWN => {
            switch (e.*.mouse_button) {
                .LEFT => {
                    state.input.mouse_left = true;
                },
                .RIGHT => {
                    state.input.mouse_right = true;
                },
                .MIDDLE => {
                    state.input.mouse_middle = true;
                },
                .INVALID => {},
            }
        },
        .MOUSE_UP => {
            switch (e.*.mouse_button) {
                .LEFT => {
                    state.input.mouse_left = false;
                },
                .RIGHT => {
                    state.input.mouse_right = false;
                },
                .MIDDLE => {
                    state.input.mouse_middle = false;
                },
                .INVALID => {},
            }
        },
        .MOUSE_MOVE => {
            state.input.mouse_x = e.*.mouse_x;
            state.input.mouse_y = e.*.mouse_y;
        },
        .MOUSE_SCROLL => {
            state.input.mouse_wheel = e.*.scroll_y;
        },
        else => {},
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
        .event_cb = event,
        .width = SCR_WIDTH,
        .height = SCR_HEIGHT,
        .high_dpi = true,
        .window_title = TITLE,
    });
}
