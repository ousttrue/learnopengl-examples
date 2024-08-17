// The typical debug UI overlay useful for most sokol-app samples
const sokol = @import("sokol");

// static sgimgui_t sgimgui;

pub fn setup(sample_count: i32) void {
    _ = sample_count; // autofix
}

pub fn shutdown() void {}

pub fn draw() void {}

pub export fn event(e: [*c]const sokol.app.Event) void {
    _ = e;
}

pub fn event_with_retval(e: [*c]const sokol.app.Event) bool {
    _ = e;
    return false;
}
