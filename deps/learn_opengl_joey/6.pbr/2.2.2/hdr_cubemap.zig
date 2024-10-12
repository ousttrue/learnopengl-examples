const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const rowmath = @import("rowmath");
const InputState = rowmath.InputState;
const OrbitCamera = rowmath.OrbitCamera;
const FloatTexture = @import("FloatTexture.zig");
const EnvCubemap = @import("EnvCubemap.zig");
const Quad = @import("Quad.zig");

const SCR_WIDTH = 1280;
const SCR_HEIGHT = 720;
const TITLE = "hdr_cubemap";

const state = struct {
    var input = InputState{};
    var orbit = OrbitCamera{};
    var env_cubemap: ?EnvCubemap = null;
    var quad: Quad = undefined;
    var fetch_buffer: [1024 * 1024 * 5]u8 = undefined;
    var hdr_texture: ?FloatTexture = null;
};

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });
    sokol.time.setup();

    state.quad = Quad.init();

    sokol.fetch.setup(.{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
    });
    _ = sokol.fetch.send(.{
        .path = "resources/textures/hdr/newport_loft.hdr",
        .callback = hdr_texture_callback,
        .buffer = sokol.fetch.asRange(&state.fetch_buffer),
    });
    std.debug.print("\n\n", .{});
}

export fn hdr_texture_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        const texture = FloatTexture.load(
            response.*.data.ptr,
            response.*.data.size,
        ) catch @panic("FloatTexture.load");
        state.hdr_texture = texture;

        const env_cubemap = EnvCubemap.init();
        env_cubemap.render(texture);
        state.env_cubemap = env_cubemap;
    } else if (response.*.failed) {
        std.debug.print("[hdr_texture_callback] failed\n", .{});
    }
}

export fn frame() void {
    sokol.fetch.dowork();
    defer sg.commit();

    state.input.screen_width = sokol.app.widthf();
    state.input.screen_height = sokol.app.heightf();
    state.orbit.frame(state.input);
    state.input.mouse_wheel = 0;

    const pass_action = sg.PassAction{
        .depth = .{
            .load_action = .CLEAR,
            .clear_value = 1,
        },
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
    defer sg.endPass();
    sg.applyViewport(0, 0, sokol.app.width(), sokol.app.height(), false);

    // if (state.hdr_texture) |hdr_texture| {
    //     state.quad.draw(.{
    //         .image = hdr_texture.image,
    //         .sampler = hdr_texture.sampler,
    //     });
    // }
    if (state.env_cubemap) |cubemap| {
        const view = state.orbit.viewMatrix();
        const projection = state.orbit.projectionMatrix();
        cubemap.draw(.{ .view = view, .projection = projection });
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
        .logger = .{ .func = sokol.log.func },
    });
}
