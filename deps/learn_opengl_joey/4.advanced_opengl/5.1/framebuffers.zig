// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/4.advanced_opengl/5.1.framebuffers/framebuffers.cpp
const std = @import("std");
const builtin = @import("builtin");
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("framebuffers.glsl.zig");
const screen_shader = @import("screen.glsl.zig");
const rowmath = @import("rowmath");
const InputState = rowmath.InputState;
const OrbitCamera = rowmath.OrbitCamera;
const Mat4 = rowmath.Mat4;
const Texture = @import("Texture.zig");
const FrameBuffer = @import("FrameBuffer.zig");

const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;
const TITLE = "6.5.1 framebuffers";
var fetch_buffer: [1024 * 1024 * 2]u8 = undefined;

const state = struct {
    var input = InputState{};
    var orbit = OrbitCamera{};

    var cube_vbo = sg.Buffer{};
    var cube_texture: ?Texture = null;
    var plane_vbo = sg.Buffer{};
    var plane_texture: ?Texture = null;

    var fbo: FrameBuffer = undefined;
    var screen_vbo = sg.Buffer{};
    var pip = sg.Pipeline{};
    var screen_pip = sg.Pipeline{};
};

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });
    sokol.time.setup();

    const cubeVertices = [_]f32{
        // positions          // texture Coords
        -0.5, -0.5, -0.5, 0.0, 0.0,
        0.5,  -0.5, -0.5, 1.0, 0.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        -0.5, 0.5,  -0.5, 0.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 0.0,

        -0.5, -0.5, 0.5,  0.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        -0.5, 0.5,  0.5,  0.0, 1.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,

        -0.5, 0.5,  0.5,  1.0, 0.0,
        -0.5, 0.5,  -0.5, 1.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,
        -0.5, 0.5,  0.5,  1.0, 0.0,

        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, 0.5,  0.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,

        -0.5, -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, -0.5, 1.0, 1.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,

        -0.5, 0.5,  -0.5, 0.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5, 0.5,  0.5,  0.0, 0.0,
        -0.5, 0.5,  -0.5, 0.0, 1.0,
    };
    state.cube_vbo = sg.makeBuffer(.{
        .label = "cube",
        .data = sg.asRange(&cubeVertices),
    });

    const planeVertices = [_]f32{
        // positions          // texture Coords
        5.0,  -0.5, 5.0,  2.0, 0.0,
        -5.0, -0.5, 5.0,  0.0, 0.0,
        -5.0, -0.5, -5.0, 0.0, 2.0,

        5.0,  -0.5, 5.0,  2.0, 0.0,
        -5.0, -0.5, -5.0, 0.0, 2.0,
        5.0,  -0.5, -5.0, 2.0, 2.0,
    };

    state.plane_vbo = sg.makeBuffer(.{
        .label = "plane",
        .data = sg.asRange(&planeVertices),
    });
    {
        var pip_desc = sg.PipelineDesc{
            .label = "framebuffer",
            .shader = sg.makeShader(shader.framebuffersShaderDesc(
                sg.queryBackend(),
            )),
            .depth = .{
                .pixel_format = .DEPTH,
                .write_enabled = true,
                .compare = .LESS,
            },
        };
        pip_desc.colors[0].pixel_format = .RGBA8;
        pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
        pip_desc.layout.attrs[shader.ATTR_vs_aTexCoords].format = .FLOAT2;
        state.pip = sg.makePipeline(pip_desc);
    }

    //
    // screen
    //
    const quadVertices: [6 * 4]f32 = if (builtin.cpu.arch == .wasm32)
        // vertex attributes for a quad that fills the entire screen in Normalized Device Coordinates.
        .{
            // positions   // texCoords
            -1.0, 1.0,  0.0, 1.0,
            -1.0, -1.0, 0.0, 0.0,
            1.0,  -1.0, 1.0, 0.0,

            -1.0, 1.0,  0.0, 1.0,
            1.0,  -1.0, 1.0, 0.0,
            1.0,  1.0,  1.0, 1.0,
        }
    else
        // reverse y. d3d ?
        .{
            -1.0, 1.0,  0.0, 0.0,
            -1.0, -1.0, 0.0, 1.0,
            1.0,  -1.0, 1.0, 1.0,

            -1.0, 1.0,  0.0, 0.0,
            1.0,  -1.0, 1.0, 1.0,
            1.0,  1.0,  1.0, 0.0,
        };

    state.screen_vbo = sg.makeBuffer(.{
        .label = "quad",
        .data = sg.asRange(&quadVertices),
    });
    {
        var pip_desc = sg.PipelineDesc{
            .label = "screen",
            .shader = sg.makeShader(screen_shader.screenShaderDesc(
                sg.queryBackend(),
            )),
            // .depth = .{
            //     .write_enabled = true,
            //     .compare = .LESS,
            // },
        };
        pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT2;
        pip_desc.layout.attrs[shader.ATTR_vs_aTexCoords].format = .FLOAT2;
        state.screen_pip = sg.makePipeline(pip_desc);
    }

    state.fbo = FrameBuffer.init();
    // draw as wireframe
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    sokol.fetch.setup(.{
        .max_requests = 2,
        .num_channels = 1,
        .num_lanes = 1,
    });
    _ = sokol.fetch.send(.{
        .path = "resources/textures/container.jpg",
        .callback = cube_texture_callback,
        .buffer = sokol.fetch.asRange(&fetch_buffer),
    });
    _ = sokol.fetch.send(.{
        .path = "resources/textures/metal.png",
        .callback = plane_texture_callback,
        .buffer = sokol.fetch.asRange(&fetch_buffer),
    });
}

export fn cube_texture_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (Texture.load(response.*.data.ptr, response.*.data.size)) |texture| {
            state.cube_texture = texture;
        } else |_| {
            std.debug.print("[cube]Texture.load failed\n", .{});
        }
    } else if (response.*.failed) {
        std.debug.print("[cube]fetch failed\n", .{});
    }
}

export fn plane_texture_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (Texture.load(response.*.data.ptr, response.*.data.size)) |texture| {
            state.plane_texture = texture;
        } else |_| {
            std.debug.print("[plane]Texture.load failed\n", .{});
        }
    } else if (response.*.failed) {
        std.debug.print("[plane]fetch failed\n", .{});
    }
}

export fn frame() void {
    sokol.fetch.dowork();
    defer sg.commit();

    state.input.screen_width = sokol.app.widthf();
    state.input.screen_height = sokol.app.heightf();
    state.orbit.frame(state.input);
    state.input.mouse_wheel = 0;
    const view = state.orbit.viewMatrix();
    const projection = state.orbit.projectionMatrix();

    {
        //
        // render to framebuffer
        //
        var pass_action = sg.PassAction{};
        pass_action.colors[0] =
            .{
            .load_action = .CLEAR,
            .clear_value = .{ .r = 0.1, .g = 0.1, .b = 0.1, .a = 1.0 },
        };
        sg.beginPass(.{
            .action = pass_action,
            .attachments = state.fbo.attachments,
        });
        defer sg.endPass();

        sg.applyPipeline(state.pip);
        if (state.cube_texture) |texture| {
            // cubes
            var bind = sg.Bindings{};
            bind.vertex_buffers[0] = state.cube_vbo;
            bind.fs.images[shader.SLOT_texture1] = texture.image;
            bind.fs.samplers[shader.SLOT_texture1Sampler] = texture.sampler;
            sg.applyBindings(bind);
            {
                const vs_params = shader.VsParams{
                    .model = Mat4.makeTranslation(.{ .x = -1.0, .y = 0.0, .z = -1.0 }).m,
                    .view = view.m,
                    .projection = projection.m,
                };
                sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(&vs_params));
                sg.draw(0, 36, 1);
            }
            {
                const vs_params = shader.VsParams{
                    .model = Mat4.makeTranslation(.{ .x = 2.0, .y = 0.0, .z = 0.0 }).m,
                    .view = view.m,
                    .projection = projection.m,
                };
                sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(&vs_params));
                sg.draw(0, 36, 1);
            }
        }
        if (state.plane_texture) |texture| {
            var bind = sg.Bindings{};
            bind.vertex_buffers[0] = state.plane_vbo;
            bind.fs.images[shader.SLOT_texture1] = texture.image;
            bind.fs.samplers[shader.SLOT_texture1Sampler] = texture.sampler;
            sg.applyBindings(bind);
            const vs_params = shader.VsParams{
                .model = Mat4.identity.m,
                .view = view.m,
                .projection = projection.m,
            };
            sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(&vs_params));
            sg.draw(0, 6, 1);
        }
    }

    {
        //
        // render screen to swapchain(post effect)
        //
        var pass_action = sg.PassAction{};
        pass_action.colors[0] =
            .{
            .load_action = .CLEAR,
            // set clear color to white (not really necessary actually, since we won't be able to see behind the quad anyways)
            .clear_value = .{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 1.0 },
        };
        sg.beginPass(.{
            .action = pass_action,
            .swapchain = sokol.glue.swapchain(),
        });
        defer sg.endPass();

        {
            sg.applyPipeline(state.screen_pip);
            var bind = sg.Bindings{};
            bind.vertex_buffers[0] = state.screen_vbo;
            bind.fs.images[screen_shader.SLOT_screenTexture] = state.fbo.image;
            bind.fs.samplers[screen_shader.SLOT_screenTextureSampler] = state.fbo.sampler;
            sg.applyBindings(bind);
            sg.draw(0, 6, 1);
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
