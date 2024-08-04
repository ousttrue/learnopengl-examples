const std = @import("std");
const sokol = @import("sokol");
const szmath = @import("szmath");
const Vec3 = szmath.Vec3;
const Vec2 = szmath.Vec2;
const Mat4 = szmath.Mat4;

pub const OrbitalCameraDesc = struct {
    target: Vec3 = Vec3.zero(),
    up: Vec3 = Vec3.zero(),
    pitch: f32 = 0,
    heading: f32 = 0,
    distance: f32 = 0,
    // camera limits
    min_pitch: f32 = 0,
    max_pitch: f32 = 0,
    min_dist: f32 = 0,
    max_dist: f32 = 0,
    // control options
    zoom_speed: f32 = 0,

    pub fn calc_position(self: *@This()) Vec3 {
        const cos_p = std.math.cos(std.math.degreesToRadians(self.pitch));
        const sin_p = std.math.sin(std.math.degreesToRadians(self.pitch));
        const cos_h = std.math.cos(std.math.degreesToRadians(self.heading));
        const sin_h = std.math.sin(std.math.degreesToRadians(self.heading));
        return .{
            .x = self.distance * cos_p * sin_h,
            .y = self.distance * -sin_p,
            .z = self.distance * cos_p * cos_h,
        };
    }

    pub fn yaw_pitch(camera: *@This(), mouse_offset: Vec2) void {
        camera.heading -= mouse_offset.x;
        camera.pitch += std.math.clamp(mouse_offset.y, camera.min_pitch, camera.max_pitch);
    }

    pub fn dolly(camera: *@This(), val: f32) void {
        const new_dist = camera.distance - val * camera.zoom_speed;
        camera.distance = std.math.clamp(new_dist, camera.min_dist, camera.max_dist);
    }
};

pub const OrbitalCamera = struct {
    desc: OrbitalCameraDesc = .{},
    enable_rotate: bool = false,
    // internal state
    position: Vec3 = Vec3.zero(),
    last_touch: [sokol.app.max_touchpoints]Vec2 = undefined,

    pub fn view_matrix(self: @This()) Mat4 {
        return Mat4.lookat(self.position, self.desc.target, self.desc.up);
    }

    pub fn handle_input(
        camera: *@This(),
        e: [*c]const sokol.app.Event,
        mouse_offset: Vec2,
    ) void {
        if (e.*.type == .MOUSE_DOWN) {
            if (e.*.mouse_button == .LEFT) {
                camera.enable_rotate = true;
            }
        } else if (e.*.type == .MOUSE_UP) {
            if (e.*.mouse_button == .LEFT) {
                camera.enable_rotate = false;
            }
        } else if (e.*.type == .MOUSE_MOVE) {
            if (camera.enable_rotate) {
                camera.desc.yaw_pitch(mouse_offset);
            }
        } else if (e.*.type == .MOUSE_SCROLL) {
            camera.desc.dolly(e.*.scroll_y);
        } else if (e.*.type == .TOUCHES_BEGAN) {
            for (0..@intCast(e.*.num_touches)) |i| {
                const touch = &e.*.touches[i];
                camera.last_touch[touch.identifier].x = touch.pos_x;
                camera.last_touch[touch.identifier].y = touch.pos_y;
            }
        } else if (e.*.type == .TOUCHES_MOVED) {
            if (e.*.num_touches == 1) {
                const touch = &e.*.touches[0];
                const last_touch = &camera.last_touch[touch.identifier];

                var _offset = Vec2{ .x = 0.0, .y = 0.0 };

                _offset.x = touch.pos_x - last_touch.x;
                _offset.y = last_touch.y - touch.pos_y;

                // reduce speed of touch controls
                _offset.x *= 0.3;
                _offset.y *= 0.3;

                camera.desc.yaw_pitch(_offset);
            } else if (e.*.num_touches == 2) {
                const touch0 = &e.*.touches[0];
                const touch1 = &e.*.touches[1];

                const v0 = Vec2{ .x = touch0.pos_x, .y = touch0.pos_y };
                const v1 = Vec2{ .x = touch1.pos_x, .y = touch1.pos_y };

                const prev_v0 = &camera.last_touch[touch0.identifier];
                const prev_v1 = &camera.last_touch[touch1.identifier];

                const length0 = v1.distance(v0);
                const length1 = prev_v1.distance(prev_v0.*);

                var diff = length0 - length1;
                // reduce speed of touch controls
                diff *= 0.1;

                camera.desc.dolly(diff);
            }

            // update all touch coords
            for (0..@intCast(e.*.num_touches)) |i| {
                const touch = &e.*.touches[i];
                camera.last_touch[touch.identifier].x = touch.pos_x;
                camera.last_touch[touch.identifier].y = touch.pos_y;
            }
        }

        camera.position = camera.desc.calc_position();
    }

    pub fn help(_: @This()) [:0]const u8 {
        return "Look:\t\tleft-mouse-btn\n" ++
            "Zoom:\t\tmouse-scroll\n";
    }
};
