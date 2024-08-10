//------------------------------------------------------------------------------
//  ozz-anim-sapp.cc
//
//  https://guillaumeblanc.github.io/ozz-animation/
//
//  Port of the ozz-animation "Animation Playback" sample. Use sokol-gl
//  for debug-rendering the animated character skeleton (no skinning).
//------------------------------------------------------------------------------
const std = @import("std");
const szmath = @import("szmath");
const sokol = @import("sokol");
const sg = sokol.gfx;
const simgui = sokol.imgui;

const util_camera = @import("util_camera");
const ozz_wrap = @import("ozz_wrap.zig");

const state = struct {
    var ozz: *anyopaque = undefined;
    const loaded = struct {
        var skeleton = false;
        var animation = false;
        var failed = false;
    };
    var pass_action = sg.PassAction{};
    var camera: util_camera.Camera = .{};

    const time = struct {
        var frame: f64 = 0;
        var absolute: f64 = 0;
        var factor: f32 = 0;
        var anim_ratio: f32 = 0;
        var anim_ratio_ui_override = false;
        var paused = false;
    };
};

// io buffers for skeleton and animation data files, we know the max file size upfront
var skel_data_buffer = [1]u8{0} ** (4 * 1024);
var anim_data_buffer = [1]u8{0} ** (32 * 1024);

export fn init() void {
    state.ozz = ozz_wrap.OZZ_init();
    state.time.factor = 1.0;

    // setup sokol-gfx
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });

    // setup sokol-fetch
    sokol.fetch.setup(.{
        .max_requests = 2,
        .num_channels = 1,
        .num_lanes = 2,
        .logger = .{ .func = sokol.log.func },
    });

    // setup sokol-gl
    sokol.gl.setup(.{
        .sample_count = sokol.app.sampleCount(),
        .logger = .{ .func = sokol.log.func },
    });

    // setup sokol-imgui
    simgui.setup(.{
        .logger = .{ .func = sokol.log.func },
    });

    // initialize pass action for default-pass
    state.pass_action.colors[0].load_action = .CLEAR;
    state.pass_action.colors[0].clear_value = .{ .r = 0.0, .g = 0.1, .b = 0.2, .a = 1.0 };

    // initialize camera helper
    state.camera = util_camera.Camera.init(.{
        .min_dist = 1.0,
        .max_dist = 10.0,
        .center = .{ .x = 0, .y = 1.0, .z = 0 },
        .distance = 3.0,
        .latitude = 10.0,
        .longitude = 20.0,
    });

    // start loading the skeleton and animation files
    _ = sokol.fetch.send(.{
        .path = "sapp/data/ozz/ozz_anim_skeleton.ozz",
        .callback = skeleton_data_loaded,
        .buffer = sokol.fetch.asRange(&skel_data_buffer),
    });

    _ = sokol.fetch.send(.{
        .path = "sapp/data/ozz/ozz_anim_animation.ozz",
        .callback = animation_data_loaded,
        .buffer = sokol.fetch.asRange(&anim_data_buffer),
    });
}

export fn frame() void {
    sokol.fetch.dowork();

    const fb_width = sokol.app.width();
    const fb_height = sokol.app.height();
    state.time.frame = sokol.app.frameDuration();
    state.camera.update(fb_width, fb_height);

    simgui.newFrame(.{
        .width = fb_width,
        .height = fb_height,
        .delta_time = state.time.frame,
        .dpi_scale = sokol.app.dpiScale(),
    });
    draw_ui();

    if (state.loaded.skeleton and state.loaded.animation) {
        if (!state.time.paused) {
            state.time.absolute += state.time.frame * state.time.factor;
        }

        // convert current time to animation ration (0.0 .. 1.0)
        const anim_duration = ozz_wrap.OZZ_duration(state.ozz);
        if (!state.time.anim_ratio_ui_override) {
            state.time.anim_ratio = std.math.mod(
                f32,
                @as(f32, @floatCast(state.time.absolute)) / anim_duration,
                1.0,
            ) catch unreachable;
        }

        ozz_wrap.OZZ_eval_animation(state.ozz, state.time.anim_ratio);
        draw_skeleton(state.ozz);
    }

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sokol.gl.draw();
    simgui.render();
    sg.endPass();
    sg.commit();
}

export fn input(ev: [*c]const sokol.app.Event) void {
    if (simgui.handleEvent(ev.*)) {
        return;
    }
    state.camera.handleEvent(ev);
}

export fn cleanup() void {
    simgui.shutdown();
    sokol.gl.shutdown();
    sokol.fetch.shutdown();
    sg.shutdown();

    // free C++ objects early, otherwise ozz-animation complains about memory leaks
    ozz_wrap.OZZ_shutdown(state.ozz);
}

fn draw_vec(vec: szmath.Vec3) void {
    sokol.gl.v3f(vec.x, vec.y, vec.z);
}

fn draw_line(v0: szmath.Vec3, v1: szmath.Vec3) void {
    draw_vec(v0);
    draw_vec(v1);
}

// this draws a wireframe 3d rhombus between the current and parent joints
fn draw_joint(ozz: *anyopaque, joint_index: usize, parent_joint_index: u16) void {
    if (parent_joint_index == std.math.maxInt(u16)) {
        return;
    }

    const m0 = ozz_wrap.OZZ_model_matrices(ozz, joint_index).*;
    const m1 = ozz_wrap.OZZ_model_matrices(ozz, @intCast(parent_joint_index)).*;

    const p0 = m0.row3().toVec3();
    const p1 = m1.row3().toVec3();
    const ny = m1.row1().toVec3();
    const nz = m1.row2().toVec3();

    const len = p1.sub(p0).len() * 0.1;
    const pmid = p0.add((p1.sub(p0)).mul(0.66));
    const p2 = pmid.add(ny.mul(len));
    const p3 = pmid.add(nz.mul(len));
    const p4 = pmid.sub(ny.mul(len));
    const p5 = pmid.sub(nz.mul(len));

    sokol.gl.c3f(1.0, 1.0, 0.0);
    draw_line(p0, p2);
    draw_line(p0, p3);
    draw_line(p0, p4);
    draw_line(p0, p5);
    draw_line(p1, p2);
    draw_line(p1, p3);
    draw_line(p1, p4);
    draw_line(p1, p5);
    draw_line(p2, p3);
    draw_line(p3, p4);
    draw_line(p4, p5);
    draw_line(p5, p2);
}

fn draw_skeleton(ozz: *anyopaque) void {
    if (!state.loaded.skeleton) {
        return;
    }
    sokol.gl.defaults();
    sokol.gl.matrixModeProjection();
    sokol.gl.loadMatrix(&state.camera.proj.m[0]);
    sokol.gl.matrixModeModelview();
    sokol.gl.loadMatrix(&state.camera.view.m[0]);

    const num_joints = ozz_wrap.OZZ_num_joints(ozz);
    const joint_parents = ozz_wrap.OZZ_joint_parents(ozz);
    sokol.gl.beginLines();

    sokol.gl.c3f(1.0, 0.0, 0.0);
    sokol.gl.v3f(0, 0, 0);
    sokol.gl.v3f(1, 0, 0);
    sokol.gl.c3f(0.0, 1.0, 0.0);
    sokol.gl.v3f(0, 0, 0);
    sokol.gl.v3f(0, 1, 0);
    sokol.gl.c3f(0.0, 0.0, 1.0);
    sokol.gl.v3f(0, 0, 0);
    sokol.gl.v3f(0, 0, 1);

    for (0..num_joints) |joint_index| {
        if (joint_index == std.math.maxInt(u16)) {
            continue;
        }
        draw_joint(ozz, joint_index, joint_parents[joint_index]);
    }
    sokol.gl.end();
}

fn draw_ui() void {
    //     ImGui::SetNextWindowPos({ 20, 20 }, ImGuiCond_Once);
    //     ImGui::SetNextWindowSize({ 220, 150 }, ImGuiCond_Once);
    //     ImGui::SetNextWindowBgAlpha(0.35f);
    //     if (ImGui::Begin("Controls", nullptr, ImGuiWindowFlags_NoDecoration|ImGuiWindowFlags_AlwaysAutoResize)) {
    //         if (state.loaded.failed) {
    //             ImGui::Text("Failed loading character data!");
    //         }
    //         else {
    //             ImGui::Text("Camera Controls:");
    //             ImGui::Text("  LMB + Mouse Move: Look");
    //             ImGui::Text("  Mouse Wheel: Zoom");
    //             ImGui::SliderFloat("Distance", &state.camera.distance, state.camera.min_dist, state.camera.max_dist, "%.1f", 1.0f);
    //             ImGui::SliderFloat("Latitude", &state.camera.latitude, state.camera.min_lat, state.camera.max_lat, "%.1f", 1.0f);
    //             ImGui::SliderFloat("Longitude", &state.camera.longitude, 0.0f, 360.0f, "%.1f", 1.0f);
    //             ImGui::Separator();
    //             ImGui::Text("Time Controls:");
    //             ImGui::Checkbox("Paused", &state.time.paused);
    //             ImGui::SliderFloat("Factor", &state.time.factor, 0.0f, 10.0f, "%.1f", 1.0f);
    //             if (ImGui::SliderFloat("Ratio", &state.time.anim_ratio, 0.0f, 1.0f)) {
    //                 state.time.anim_ratio_ui_override = true;
    //             }
    //             if (ImGui::IsItemDeactivatedAfterEdit()) {
    //                 state.time.anim_ratio_ui_override = false;
    //             }
    //         }
    //     }
    //     ImGui::End();
}

export fn skeleton_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (ozz_wrap.OZZ_load_skeleton(
            state.ozz,
            response.*.data.ptr,
            response.*.data.size,
        )) {
            state.loaded.skeleton = true;
        } else {
            state.loaded.failed = true;
        }
    } else if (response.*.failed) {
        state.loaded.failed = true;
    }
}

export fn animation_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (ozz_wrap.OZZ_load_animation(
            state.ozz,
            response.*.data.ptr,
            response.*.data.size,
        )) {
            state.loaded.animation = true;
        } else {
            state.loaded.failed = true;
        }
    } else if (response.*.failed) {
        state.loaded.failed = true;
    }
}

pub fn main() void {
    sokol.app.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "ozz-anim-sapp.cc",
        .icon = .{ .sokol_default = true },
        .logger = .{ .func = sokol.log.func },
    });
}
