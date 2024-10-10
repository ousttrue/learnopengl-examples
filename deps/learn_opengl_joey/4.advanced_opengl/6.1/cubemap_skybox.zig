// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/4.advanced_opengl/6.1.cubemaps_skybox/cubemaps_skybox.cpp
const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const rowmath = @import("rowmath");
const InputState = rowmath.InputState;
const OrbitCamera = rowmath.OrbitCamera;
const Mat4 = rowmath.Mat4;
const cubemap_shader = @import("cubemap.glsl.zig");
const skybox_shader = @import("skybox.glsl.zig");
const fetcher = @import("fetcher.zig");
const Image = @import("Image.zig");
const Cubemap = @import("Cubemap.zig");
const Texture = @import("Texture.zig");

// settings
const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;
const TITLE = "4.6.1 cubemaps_skybox";

const src = [6][:0]const u8{
    "skybox_right.jpg",
    "skybox_left.jpg",
    "skybox_top.jpg",
    "skybox_bottom.jpg",
    "skybox_front.jpg",
    "skybox_back.jpg",
};
const TEXTURE = "container.jpg";

const state = struct {
    var input = InputState{};
    var orbit = OrbitCamera{
        // .camera = .{ .projection = .{
        //     .far_clip = 100,
        // } },
    };

    var cubemap_vbo = sg.Buffer{};
    var cubemap_pip = sg.Pipeline{};
    var texture: ?Texture = null;

    var skybox_vbo = sg.Buffer{};
    var skybox_pip = sg.Pipeline{};
    var skybox: ?Cubemap = null;
};

var fetch_buffer: [1024 * 512]u8 = undefined;

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
    state.cubemap_vbo = sg.makeBuffer(.{
        .data = sg.asRange(&cubeVertices),
        .label = "cubemap",
    });
    {
        var pip_desc = sg.PipelineDesc{
            .label = "cubemap",
            .shader = sg.makeShader(cubemap_shader.cubemapShaderDesc(
                sg.queryBackend(),
            )),
            .depth = .{
                .write_enabled = true,
                .compare = .LESS,
            },
        };
        pip_desc.layout.attrs[cubemap_shader.ATTR_vs_aPos].format = .FLOAT3;
        pip_desc.layout.attrs[cubemap_shader.ATTR_vs_aTexCoords].format = .FLOAT2;
        state.cubemap_pip = sg.makePipeline(pip_desc);
    }

    const skyboxVertices = [_]f32{
        // positions
        -1.0, 1.0,  -1.0,
        -1.0, -1.0, -1.0,
        1.0,  -1.0, -1.0,
        1.0,  -1.0, -1.0,
        1.0,  1.0,  -1.0,
        -1.0, 1.0,  -1.0,

        -1.0, -1.0, 1.0,
        -1.0, -1.0, -1.0,
        -1.0, 1.0,  -1.0,
        -1.0, 1.0,  -1.0,
        -1.0, 1.0,  1.0,
        -1.0, -1.0, 1.0,

        1.0,  -1.0, -1.0,
        1.0,  -1.0, 1.0,
        1.0,  1.0,  1.0,
        1.0,  1.0,  1.0,
        1.0,  1.0,  -1.0,
        1.0,  -1.0, -1.0,

        -1.0, -1.0, 1.0,
        -1.0, 1.0,  1.0,
        1.0,  1.0,  1.0,
        1.0,  1.0,  1.0,
        1.0,  -1.0, 1.0,
        -1.0, -1.0, 1.0,

        -1.0, 1.0,  -1.0,
        1.0,  1.0,  -1.0,
        1.0,  1.0,  1.0,
        1.0,  1.0,  1.0,
        -1.0, 1.0,  1.0,
        -1.0, 1.0,  -1.0,

        -1.0, -1.0, -1.0,
        -1.0, -1.0, 1.0,
        1.0,  -1.0, -1.0,
        1.0,  -1.0, -1.0,
        -1.0, -1.0, 1.0,
        1.0,  -1.0, 1.0,
    };
    state.skybox_vbo = sg.makeBuffer(.{
        .data = sg.asRange(&skyboxVertices),
        .label = "skybox",
    });
    {
        var pip_desc = sg.PipelineDesc{
            .label = "skybox",
            .shader = sg.makeShader(skybox_shader.skyboxShaderDesc(
                sg.queryBackend(),
            )),
            .depth = .{
                .write_enabled = true,
                .compare = .LESS_EQUAL,
            },
            .cull_mode = .NONE,
        };
        pip_desc.layout.attrs[skybox_shader.ATTR_vs_aPos].format = .FLOAT3;
        state.skybox_pip = sg.makePipeline(pip_desc);
    }

    sokol.fetch.setup(.{
        .max_requests = 7,
        .num_channels = 1,
        .num_lanes = 2,
    });

    _ = sokol.fetch.send(.{
        .path = TEXTURE,
        .callback = fetch_callback,
        .buffer = sokol.fetch.asRange(&fetch_buffer),
    });

    fetcher.fetch(std.heap.c_allocator, &src, 2048, on_download) catch @panic("fetcher.fetch");
}

export fn fetch_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (Texture.load(response.*.data.ptr, response.*.data.size)) |texture| {
            state.texture = texture;
        } else |_| {
            std.debug.print("Texture.load failed\n", .{});
        }
    } else if (response.*.failed) {
        std.debug.print("fetch failed\n", .{});
    }
}

fn on_download(images: []const Image) void {
    std.debug.assert(images.len == 6);
    state.skybox = Cubemap.init(images);
    std.debug.print("creat cubemap\n", .{});
}

export fn frame() void {
    sokol.fetch.dowork();

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

        if (state.texture) |texture| {
            sg.applyPipeline(state.cubemap_pip);
            var bind = sg.Bindings{};
            bind.vertex_buffers[0] = state.cubemap_vbo;
            bind.fs.images[cubemap_shader.SLOT_texture1] = texture.image;
            bind.fs.samplers[cubemap_shader.SLOT_texture1Sampler] = texture.sampler;
            sg.applyBindings(bind);
            const vs_params = cubemap_shader.VsParams{
                .view = state.orbit.viewMatrix().m,
                .projection = state.orbit.projectionMatrix().m,
                .model = Mat4.identity.m,
            };
            sg.applyUniforms(.VS, cubemap_shader.SLOT_vs_params, sg.asRange(&vs_params));
            sg.draw(0, 36, 1);
        }

        // draw skybox as last
        if (state.skybox) |skybox| {
            // skybox cube
            sg.applyPipeline(state.skybox_pip);
            var bind = sg.Bindings{};
            bind.vertex_buffers[0] = state.skybox_vbo;
            bind.fs.images[skybox_shader.SLOT_skybox] = skybox.image;
            bind.fs.samplers[skybox_shader.SLOT_skyboxSampler] = skybox.sampler;
            sg.applyBindings(bind);
            var vs_params = skybox_shader.VsParams{
                .view = state.orbit.viewMatrix().m,
                .projection = state.orbit.projectionMatrix().m,
            };
            vs_params.view[12] = 0;
            vs_params.view[13] = 0;
            vs_params.view[14] = 0;
            sg.applyUniforms(.VS, skybox_shader.SLOT_vs_params, sg.asRange(&vs_params));
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
