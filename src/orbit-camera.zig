const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const szmath = @import("szmath");

const state = struct {
    var pass_action = sg.PassAction{};
    var input = szmath.InputState{
        .screen_width = 1,
        .screen_height = 1,
    };
    var camera = szmath.Camera{
        // .yFov = 60,
        // .near_clip = 0.5,
        // .far_clip = 15,
        .transform = .{
            .translation = .{
                .x = 0,
                .y = 0.5,
                .z = 5,
            },
        },
    };
};

fn grid() void {
    const n = 5.0;
    sokol.gl.beginLines();
    sokol.gl.c3f(1, 1, 1);
    {
        var x: f32 = -n;
        while (x <= n) : (x += 1) {
            sokol.gl.v3f(x, 0, -n);
            sokol.gl.v3f(x, 0, n);
        }
    }
    {
        var z: f32 = -n;
        while (z <= n) : (z += 1) {
            sokol.gl.v3f(-n, 0, z);
            sokol.gl.v3f(n, 0, z);
        }
    }
    sokol.gl.end();
}

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.1, .g = 0.1, .b = 0.1, .a = 1.0 },
    };
    sokol.gl.setup(.{
        .logger = .{ .func = sokol.log.func },
    });
}

export fn frame() void {
    _ = state.camera.update(state.input);
    // std.debug.print("{any}\n", .{state.camera.transform.worldToLocal()});

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sokol.gl.setContext(sokol.gl.defaultContext());
    sokol.gl.defaults();
    sokol.gl.matrixModeProjection();
    sokol.gl.multMatrix(&state.camera.projection.m[0]);
    sokol.gl.matrixModeModelview();
    sokol.gl.multMatrix(&state.camera.transform.worldToLocal().m[0]);
    grid();
    sokol.gl.contextDraw(sokol.gl.defaultContext());

    sg.endPass();
    sg.commit();
}

export fn event(e: [*c]const sokol.app.Event) void {
    switch (e.*.type) {
        .RESIZED => {
            state.input.screen_width = @floatFromInt(e.*.window_width);
            state.input.screen_height = @floatFromInt(e.*.window_height);
        },
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
        .MOUSE_SCROLL => {},
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
        .width = 800,
        .height = 600,
        .window_title = "Clear (sokol app)",
        .icon = .{ .sokol_default = true },
        .logger = .{ .func = sokol.log.func },
    });
}
