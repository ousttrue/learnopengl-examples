const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const szmath = @import("szmath");

// /*=== ORBITAL CAM ==================================================*/

const OrbitalCamera = struct {
    // camera config
    target: szmath.Vec3 = szmath.Vec3.zero(),
    up: szmath.Vec3 = szmath.Vec3.zero(),
    polar: szmath.Vec2 = szmath.Vec2.zero(),
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

    fn update_vectors(self: *@This()) void {
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
};

const OrbitalCameraDesc = struct {
    target: szmath.Vec3,
    up: szmath.Vec3,
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

const State = struct {
    orbital_cam: OrbitalCamera = .{},
    //     struct fp_cam fp_cam;
    //     bool fp_enabled;
    //     bool show_help;
    //     bool hide_ui;
    //     bool first_mouse;
    //     HMM_Vec2 last_mouse;
    //     HMM_Vec2 last_touch[SAPP_MAX_TOUCHPOINTS];
    //     uint64_t time_stamp;
    //     uint64_t frame_time;
    //     _cubemap_request_t cubemap_req;

    fn set_orbital_cam(self: *@This(), desc: OrbitalCameraDesc) void {
        // camera attributes
        self.orbital_cam.target = desc.target;
        self.orbital_cam.up = desc.up;
        self.orbital_cam.polar = .{ .x = desc.pitch, .y = desc.heading };
        self.orbital_cam.distance = desc.distance;
        // limits
        self.orbital_cam.min_pitch = desc.min_pitch;
        self.orbital_cam.max_pitch = desc.max_pitch;
        self.orbital_cam.min_dist = desc.min_dist;
        self.orbital_cam.max_dist = desc.max_dist;
        // control options
        self.orbital_cam.rotate_speed = desc.rotate_speed;
        self.orbital_cam.zoom_speed = desc.zoom_speed;
        // control state
        self.orbital_cam.enable_rotate = false;

        self.orbital_cam.update_vectors();
    }
};
var _lopgl = State{};

pub fn setup() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });

    // initialize sokol_time
    sokol.time.setup();

    var dtx_desc = sokol.debugtext.Desc{};
    dtx_desc.fonts[0] = sokol.debugtext.fontCpc();
    sokol.debugtext.setup(dtx_desc);

    // setup sokol-fetch
    //  The 1 channel and 1 lane configuration essentially serializes
    //  IO requests. Which is just fine for this example.
    sokol.fetch.setup(.{
        .max_requests = 8,
        .num_channels = 1,
        .num_lanes = 1,
    });

    // flip images vertically after loading
    // stbi_set_flip_vertically_on_load(true);

    _lopgl.set_orbital_cam(.{
        .target = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .pitch = 0.0,
        .heading = 0.0,
        .distance = 6.0,
        .zoom_speed = 0.5,
        .rotate_speed = std.math.radiansToDegrees(1.0),
        .min_dist = 1.0,
        .max_dist = 10.0,
        .min_pitch = -89.0,
        .max_pitch = 89.0,
    });
}
