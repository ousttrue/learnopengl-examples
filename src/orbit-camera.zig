const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const SokolCamera = @import("SokolCamera");

const state = struct {
    var pass_action = sg.PassAction{};
    var camera = SokolCamera{};
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
    state.camera.init();
}

export fn frame() void {
    state.camera.frame();
    // std.debug.print("{any}\n", .{state.camera.transform.worldToLocal()});

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sokol.gl.setContext(sokol.gl.defaultContext());
    sokol.gl.defaults();

    state.camera.glSetupMatrix();

    grid();
    sokol.gl.contextDraw(sokol.gl.defaultContext());

    sg.endPass();
    sg.commit();
}

export fn event(e: [*c]const sokol.app.Event) void {
    state.camera.handleEvent(e);
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
