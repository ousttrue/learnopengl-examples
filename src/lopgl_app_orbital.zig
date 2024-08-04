const std = @import("std");
const sokol = @import("sokol");
const szmath = @import("szmath");
const Vec3 = szmath.Vec3;
const Vec2 = szmath.Vec2;
const Mat4 = szmath.Mat4;

pub const OrbitalCameraDesc = struct {
    target: Vec3,
    up: Vec3,
    pitch: f32,
    heading: f32,
    distance: f32,
    // camera limits
    min_pitch: f32,
    max_pitch: f32,
    min_dist: f32,
    max_dist: f32,
    // control options
    rotate_speed: f32,
    zoom_speed: f32,
};

pub const OrbitalCamera = struct {
    // camera config
    target: Vec3 = Vec3.zero(),
    up: Vec3 = Vec3.zero(),
    polar: Vec2 = Vec2.zero(),
    distance: f32 = 0,
    // camera limits
    min_pitch: f32 = 0,
    max_pitch: f32 = 0,
    min_dist: f32 = 0,
    max_dist: f32 = 0,
    // control options
    rotate_speed: f32 = 0,
    zoom_speed: f32 = 0,
    enable_rotate: bool = false,
    // internal state
    position: szmath.Vec3 = szmath.Vec3.zero(),
    last_touch: [sokol.app.max_touchpoints]Vec2 = undefined,

    pub fn init(self: *@This(), desc: OrbitalCameraDesc) void {
        // camera attributes
        self.target = desc.target;
        self.up = desc.up;
        self.polar = .{ .x = desc.pitch, .y = desc.heading };
        self.distance = desc.distance;
        // limits
        self.min_pitch = desc.min_pitch;
        self.max_pitch = desc.max_pitch;
        self.min_dist = desc.min_dist;
        self.max_dist = desc.max_dist;
        // control options
        self.rotate_speed = desc.rotate_speed;
        self.zoom_speed = desc.zoom_speed;
        // control state
        self.enable_rotate = false;

        self.update_vectors();
    }

    pub fn view_matrix_orbital(self: @This()) Mat4 {
        return Mat4.lookat(self.position, self.target, self.up);
    }

    pub fn update_vectors(self: *@This()) void {
        const cos_p = std.math.cos(std.math.degreesToRadians(self.polar.x));
        const sin_p = std.math.sin(std.math.degreesToRadians(self.polar.x));
        const cos_h = std.math.cos(std.math.degreesToRadians(self.polar.y));
        const sin_h = std.math.sin(std.math.degreesToRadians(self.polar.y));
        self.position = .{
            .x = self.distance * cos_p * sin_h,
            .y = self.distance * -sin_p,
            .z = self.distance * cos_p * cos_h,
        };
    }

    pub fn handle_input(camera: *@This(), e: [*c]const sokol.app.Event, mouse_offset: Vec2) void {
        if (e.*.type == .MOUSE_DOWN) {
            if (e.mouse_button == .LEFT) {
                camera.enable_rotate = true;
            }
        } else if (e.type == .MOUSE_UP) {
            if (e.mouse_button == .LEFT) {
                camera.enable_rotate = false;
            }
        } else if (e.type == .MOUSE_MOVE) {
            if (camera.enable_rotate) {
                move_orbital_camera(camera, mouse_offset);
            }
        } else if (e.type == .MOUSE_SCROLL) {
            zoom_orbital_camera(camera, e.scroll_y);
        } else if (e.type == .TOUCHES_BEGAN) {
            for (0..e.num_touches) |i| {
                const touch = &e.touches[i];
                camera.last_touch[touch.identifier].X = touch.pos_x;
                camera.last_touch[touch.identifier].Y = touch.pos_y;
            }
        } else if (e.type == .TOUCHES_MOVED) {
            if (e.num_touches == 1) {
                const touch = &e.touches[0];
                const last_touch = &camera.last_touch[touch.identifier];

                var _offset = Vec2{ .x = 0.0, .y = 0.0 };

                _offset.X = touch.pos_x - last_touch.X;
                _offset.Y = last_touch.Y - touch.pos_y;

                // reduce speed of touch controls
                _offset.X *= 0.3;
                _offset.Y *= 0.3;

                move_orbital_camera(camera, _offset);
            } else if (e.num_touches == 2) {
                const touch0 = &e.touches[0];
                const touch1 = &e.touches[1];

                const v0 = Vec2{ .x = touch0.pos_x, .y = touch0.pos_y };
                const v1 = Vec2{ .x = touch1.pos_x, .y = touch1.pos_y };

                const prev_v0 = &camera.last_touch[touch0.identifier];
                const prev_v1 = &camera.last_touch[touch1.identifier];

                const length0 = v1.distance(v0);
                const length1 = prev_v1.disance(prev_v0);

                const diff = length0 - length1;
                // reduce speed of touch controls
                diff *= 0.1;

                zoom_orbital_camera(camera, diff);
            }

            // update all touch coords
            for (0..e.num_touches) |i| {
                const touch = &e.touches[i];
                camera.last_touch[touch.identifier].X = touch.pos_x;
                camera.last_touch[touch.identifier].Y = touch.pos_y;
            }
        }

        camera.update_orbital_cam_vectors();
    }

    fn move_orbital_camera(camera: *@This(), mouse_offset: Vec2) void {
        camera.polar.Y -= mouse_offset.X * camera.rotate_speed;
        const pitch = camera.polar.X + mouse_offset.Y * camera.rotate_speed;
        camera.polar.X = std.math.clamp(pitch, camera.min_pitch, camera.max_pitch);
    }

    fn zoom_orbital_camera(camera: *@This(), val: f32) void {
        const new_dist = camera.distance - val * camera.zoom_speed;
        camera.distance = std.math.clamp(new_dist, camera.min_dist, camera.max_dist);
    }

    // const char* help_orbital() {
    //     return  "Look:\t\tleft-mouse-btn\n"
    //             "Zoom:\t\tmouse-scroll\n";
    // }
};

// void lopgl_set_orbital_cam(lopgl_orbital_cam_desc_t* desc) {
//     // camera attributes
//     _lopgl.orbital_cam.target = desc->target;
//     _lopgl.orbital_cam.up = desc->up;
//     _lopgl.orbital_cam.polar = HMM_V2(desc->pitch, desc->heading);
//     _lopgl.orbital_cam.distance = desc->distance;
//     // limits
//     _lopgl.orbital_cam.min_pitch = desc->min_pitch;
// 	_lopgl.orbital_cam.max_pitch = desc->max_pitch;
// 	_lopgl.orbital_cam.min_dist = desc->min_dist;
// 	_lopgl.orbital_cam.max_dist = desc->max_dist;
//     // control options
//     _lopgl.orbital_cam.rotate_speed = desc->rotate_speed;
//     _lopgl.orbital_cam.zoom_speed = desc->zoom_speed;
//     // control state
//     _lopgl.orbital_cam.enable_rotate = false;
//
//     update_orbital_cam_vectors(&_lopgl.orbital_cam);
// }
//
// lopgl_orbital_cam_desc_t lopgl_get_orbital_cam_desc() {
//     return (lopgl_orbital_cam_desc_t) {
//         .target = _lopgl.orbital_cam.target,
//         .up = _lopgl.orbital_cam.up,
//         .pitch = _lopgl.orbital_cam.polar.X,
//         .heading = _lopgl.orbital_cam.polar.Y,
//         .distance = _lopgl.orbital_cam.distance,
//         .zoom_speed = _lopgl.orbital_cam.zoom_speed,
//         .rotate_speed = _lopgl.orbital_cam.rotate_speed,
//         .min_dist = _lopgl.orbital_cam.min_dist,
//         .max_dist = _lopgl.orbital_cam.max_dist,
//         .min_pitch = _lopgl.orbital_cam.min_pitch,
//         .max_pitch = _lopgl.orbital_cam.max_pitch
//     };
// }
