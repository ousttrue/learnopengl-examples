//  Quick'n'dirty Maya-style camera. Include after HandmadeMath.h
//  and sokol_app.h
const std = @import("std");
const sokol = @import("sokol");
const szmath = @import("szmath");

const CAMERA_DEFAULT_MIN_DIST = 2.0;
const CAMERA_DEFAULT_MAX_DIST = 30.0;
const CAMERA_DEFAULT_MIN_LAT = -85.0;
const CAMERA_DEFAULT_MAX_LAT = 85.0;
const CAMERA_DEFAULT_DIST = 5.0;
const CAMERA_DEFAULT_ASPECT = 60.0;
const CAMERA_DEFAULT_NEARZ = 0.01;
const CAMERA_DEFAULT_FARZ = 100.0;

pub const Desc = struct {
    min_dist: f32 = 0,
    max_dist: f32 = 0,
    min_lat: f32 = 0,
    max_lat: f32 = 0,
    distance: f32 = 0,
    latitude: f32 = 0,
    longitude: f32 = 0,
    aspect: f32 = 0,
    nearz: f32 = 0,
    farz: f32 = 0,
    center: szmath.Vec3 = szmath.Vec3.zero(),
};

pub const Camera = struct {
    min_dist: f32 = 0,
    max_dist: f32 = 0,
    min_lat: f32 = 0,
    max_lat: f32 = 0,
    distance: f32 = 0,
    latitude: f32 = 0,
    longitude: f32 = 0,
    aspect: f32 = 0,
    nearz: f32 = 0,
    farz: f32 = 0,
    center: szmath.Vec3 = szmath.Vec3.zero(),
    eye_pos: szmath.Vec3 = szmath.Vec3.zero(),
    view: szmath.Mat4 = szmath.Mat4.identity(),
    proj: szmath.Mat4 = szmath.Mat4.identity(),
    view_proj: szmath.Mat4 = szmath.Mat4.identity(),

    // initialize to default parameters
    pub fn init(desc: Desc) @This() {
        return .{
            .min_dist = _cam_def(desc.min_dist, CAMERA_DEFAULT_MIN_DIST),
            .max_dist = _cam_def(desc.max_dist, CAMERA_DEFAULT_MAX_DIST),
            .min_lat = _cam_def(desc.min_lat, CAMERA_DEFAULT_MIN_LAT),
            .max_lat = _cam_def(desc.max_lat, CAMERA_DEFAULT_MAX_LAT),
            .distance = _cam_def(desc.distance, CAMERA_DEFAULT_DIST),
            .center = desc.center,
            .latitude = desc.latitude,
            .longitude = desc.longitude,
            .aspect = _cam_def(desc.aspect, CAMERA_DEFAULT_ASPECT),
            .nearz = _cam_def(desc.nearz, CAMERA_DEFAULT_NEARZ),
            .farz = _cam_def(desc.farz, CAMERA_DEFAULT_FARZ),
        };
    }

    // feed mouse movement
    pub fn orbit(cam: *@This(), dx: f32, dy: f32) void {
        cam.longitude -= dx;
        if (cam.longitude < 0.0) {
            cam.longitude += 360.0;
        }
        if (cam.longitude > 360.0) {
            cam.longitude -= 360.0;
        }
        cam.latitude = std.math.clamp(cam.latitude + dy, cam.min_lat, cam.max_lat);
    }

    // feed zoom (mouse wheel) input
    pub fn zoom(cam: *@This(), d: f32) void {
        cam.distance = std.math.clamp(cam.distance + d, cam.min_dist, cam.max_dist);
    }

    // update the view, proj and view_proj matrix
    pub fn update(cam: *@This(), fb_width: i32, fb_height: i32) void {
        // assert((fb_width > 0) && (fb_height > 0));
        const w: f32 = @floatFromInt(fb_width);
        const h: f32 = @floatFromInt(fb_height);
        cam.eye_pos = cam.center.add(_cam_euclidean(cam.latitude, cam.longitude).mul(cam.distance));
        cam.view = szmath.Mat4.lookat(cam.eye_pos, cam.center, .{ .x = 0.0, .y = 1.0, .z = 0.0 });
        cam.proj = szmath.Mat4.persp(cam.aspect, w / h, cam.nearz, cam.farz);
        cam.view_proj = cam.proj.mul(cam.view);
    }

    // handle sokol-app input events
    pub fn handleEvent(cam: *@This(), ev: [*c]const sokol.app.Event) void {
        switch (ev.*.type) {
            .MOUSE_DOWN => {
                if (ev.*.mouse_button == .LEFT) {
                    sokol.app.lockMouse(true);
                }
            },
            .MOUSE_UP => {
                if (ev.*.mouse_button == .LEFT) {
                    sokol.app.lockMouse(false);
                }
            },
            .MOUSE_SCROLL => {
                cam.zoom(-ev.*.scroll_y);
            },
            .MOUSE_MOVE => {
                if (sokol.app.mouseLocked()) {
                    cam.orbit(ev.*.mouse_dx * 0.25, ev.*.mouse_dy * 0.25);
                }
            },
            else => {},
        }
    }
};

fn _cam_def(val: f32, def: f32) f32 {
    return if (val == 0.0) def else val;
}

fn _cam_euclidean(latitude: f32, longitude: f32) szmath.Vec3 {
    const lat = std.math.degreesToRadians(latitude);
    const lng = std.math.degreesToRadians(longitude);
    return .{
        .x = std.math.cos(lat) * std.math.sin(lng),
        .y = std.math.sin(lat),
        .z = std.math.cos(lat) * std.math.cos(lng),
    };
}
