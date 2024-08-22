const sokol = @import("sokol");
const rowmath = @import("rowmath");
const Mat4 = rowmath.Mat4;

camera: rowmath.Camera = .{},
input: rowmath.InputState = .{},

pub fn init(self: *@This()) void {
    self.input.screen_width = sokol.app.widthf();
    self.input.screen_height = sokol.app.heightf();
}

pub fn frame(self: *@This()) void {
    self.input.screen_width = sokol.app.widthf();
    self.input.screen_height = sokol.app.heightf();
    _ = self.camera.update(self.input);
    self.input.mouse_wheel = 0;
}

pub fn handleEvent(self: *@This(), e: [*c]const sokol.app.Event) void {
    switch (e.*.type) {
        .RESIZED => {
            self.input.screen_width = @floatFromInt(e.*.window_width);
            self.input.screen_height = @floatFromInt(e.*.window_height);
        },
        .MOUSE_DOWN => {
            switch (e.*.mouse_button) {
                .LEFT => {
                    self.input.mouse_left = true;
                },
                .RIGHT => {
                    self.input.mouse_right = true;
                },
                .MIDDLE => {
                    self.input.mouse_middle = true;
                },
                .INVALID => {},
            }
        },
        .MOUSE_UP => {
            switch (e.*.mouse_button) {
                .LEFT => {
                    self.input.mouse_left = false;
                },
                .RIGHT => {
                    self.input.mouse_right = false;
                },
                .MIDDLE => {
                    self.input.mouse_middle = false;
                },
                .INVALID => {},
            }
        },
        .MOUSE_MOVE => {
            self.input.mouse_x = e.*.mouse_x;
            self.input.mouse_y = e.*.mouse_y;
        },
        .MOUSE_SCROLL => {
            self.input.mouse_wheel = e.*.scroll_y;
        },
        else => {},
    }
}

pub fn glSetupMatrix(self: *@This()) void {
    sokol.gl.matrixModeProjection();
    sokol.gl.loadMatrix(&self.camera.projection.m[0]);
    sokol.gl.matrixModeModelview();
    sokol.gl.loadMatrix(&self.camera.transform.worldToLocal().m[0]);
}

pub fn viewProjectionMatrix(self: @This()) Mat4 {
    return self.camera.transform.worldToLocal().mul(self.camera.projection);
}
