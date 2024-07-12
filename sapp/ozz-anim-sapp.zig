//------------------------------------------------------------------------------
//  ozz-anim-sapp.cc
//
//  https://guillaumeblanc.github.io/ozz-animation/
//
//  Port of the ozz-animation "Animation Playback" sample. Use sokol-gl
//  for debug-rendering the animated character skeleton (no skinning).
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const sg = sokol.gfx;
const simgui = sokol.imgui;

const util_camera = @import("util_camera");

// ozz-animation headers
// #include "ozz/animation/runtime/animation.h"
// #include "ozz/animation/runtime/skeleton.h"
// #include "ozz/animation/runtime/sampling_job.h"
// #include "ozz/animation/runtime/local_to_model_job.h"
// #include "ozz/base/io/stream.h"
// #include "ozz/base/io/archive.h"
// #include "ozz/base/containers/vector.h"
// #include "ozz/base/maths/soa_transform.h"
// #include "ozz/base/maths/vec_float.h"

// wrapper struct for managed ozz-animation C++ objects, must be deleted
// before shutdown, otherwise ozz-animation will report a memory leak
// typedef struct {
//     ozz::animation::Skeleton skeleton;
//     ozz::animation::Animation animation;
//     ozz::animation::SamplingCache cache;
//     ozz::vector<ozz::math::SoaTransform> local_matrices;
//     ozz::vector<ozz::math::Float4x4> model_matrices;
// } ozz_t;

const state = struct {
    //     std::unique_ptr<ozz_t> ozz;
    var pass_action = sg.PassAction{};
    var camera: util_camera.Camera = .{};

    const loaded = struct {
        var skeleton = false;
        var animation = false;
        var failed = false;
    };

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
    {
        _ = sokol.fetch.send(.{
            .path = "ozz_anim_skeleton.ozz",
            .callback = skeleton_data_loaded,
            .buffer = sokol.fetch.asRange(&skel_data_buffer),
        });
    }
    {
        _ = sokol.fetch.send(.{
            .path = "ozz_anim_animation.ozz",
            .callback = animation_data_loaded,
            .buffer = sokol.fetch.asRange(&anim_data_buffer),
        });
    }
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

    if (state.loaded.animation and state.loaded.skeleton) {
        if (!state.time.paused) {
            state.time.absolute += state.time.frame * state.time.factor;
        }
        eval_animation();
        draw_skeleton();
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
    // state.ozz = nullptr;
}

fn eval_animation() void {
    //
    //     // convert current time to animation ration (0.0 .. 1.0)
    //     const float anim_duration = state.ozz->animation.duration();
    //     if (!state.time.anim_ratio_ui_override) {
    //         state.time.anim_ratio = fmodf((float)state.time.absolute / anim_duration, 1.0f);
    //     }
    //
    //     // sample animation
    //     ozz::animation::SamplingJob sampling_job;
    //     sampling_job.animation = &state.ozz->animation;
    //     sampling_job.cache = &state.ozz->cache;
    //     sampling_job.ratio = state.time.anim_ratio;
    //     sampling_job.output = make_span(state.ozz->local_matrices);
    //     sampling_job.Run();
    //
    //     // convert joint matrices from local to model space
    //     ozz::animation::LocalToModelJob ltm_job;
    //     ltm_job.skeleton = &state.ozz->skeleton;
    //     ltm_job.input = make_span(state.ozz->local_matrices);
    //     ltm_job.output = make_span(state.ozz->model_matrices);
    //     ltm_job.Run();
}

// static void draw_vec(const ozz::math::SimdFloat4& vec) {
//     sgl_v3f(ozz::math::GetX(vec), ozz::math::GetY(vec), ozz::math::GetZ(vec));
// }
//
// static void draw_line(const ozz::math::SimdFloat4& v0, const ozz::math::SimdFloat4& v1) {
//     draw_vec(v0);
//     draw_vec(v1);
// }
//
// // this draws a wireframe 3d rhombus between the current and parent joints
// static void draw_joint(int joint_index, int parent_joint_index) {
//     if (parent_joint_index < 0) {
//         return;
//     }
//
//     using namespace ozz::math;
//
//     const Float4x4& m0 = state.ozz->model_matrices[joint_index];
//     const Float4x4& m1 = state.ozz->model_matrices[parent_joint_index];
//
//     const SimdFloat4 p0 = m0.cols[3];
//     const SimdFloat4 p1 = m1.cols[3];
//     const SimdFloat4 ny = m1.cols[1];
//     const SimdFloat4 nz = m1.cols[2];
//
//     const SimdFloat4 len = SplatX(Length3(p1 - p0)) * simd_float4::Load1(0.1f);
//
//     const SimdFloat4 pmid = p0 + (p1 - p0) * simd_float4::Load1(0.66f);
//     const SimdFloat4 p2 = pmid + ny * len;
//     const SimdFloat4 p3 = pmid + nz * len;
//     const SimdFloat4 p4 = pmid - ny * len;
//     const SimdFloat4 p5 = pmid - nz * len;
//
//     sgl_c3f(1.0f, 1.0f, 0.0f);
//     draw_line(p0, p2); draw_line(p0, p3); draw_line(p0, p4); draw_line(p0, p5);
//     draw_line(p1, p2); draw_line(p1, p3); draw_line(p1, p4); draw_line(p1, p5);
//     draw_line(p2, p3); draw_line(p3, p4); draw_line(p4, p5); draw_line(p5, p2);
// }

fn draw_skeleton() void {
    //     sgl_defaults();
    //     sgl_matrix_mode_projection();
    //     sgl_load_matrix((const float*)&state.camera.proj);
    //     sgl_matrix_mode_modelview();
    //     sgl_load_matrix((const float*)&state.camera.view);
    //
    //     const int num_joints = state.ozz->skeleton.num_joints();
    //     ozz::span<const int16_t> joint_parents = state.ozz->skeleton.joint_parents();
    //     sgl_begin_lines();
    //     for (int joint_index = 0; joint_index < num_joints; joint_index++) {
    //         draw_joint(joint_index, joint_parents[joint_index]);
    //     }
    //     sgl_end();
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
        // NOTE: if we derived our own ozz::io::Stream class we could
        // avoid the extra allocation and memory copy that happens
        // with the standard MemoryStream class
        // ozz::io::MemoryStream stream;
        // stream.Write(response->data.ptr, response->data.size);
        // stream.Seek(0, ozz::io::Stream::kSet);
        // ozz::io::IArchive archive(&stream);
        // if (archive.TestTag<ozz::animation::Skeleton>()) {
        //     archive >> state.ozz->skeleton;
        //     state.loaded.skeleton = true;
        //     const int num_soa_joints = state.ozz->skeleton.num_soa_joints();
        //     const int num_joints = state.ozz->skeleton.num_joints();
        //     state.ozz->local_matrices.resize(num_soa_joints);
        //     state.ozz->model_matrices.resize(num_joints);
        //     state.ozz->cache.Resize(num_joints);
        // }
        // else {
        //     state.loaded.failed = true;
        // }
    } else if (response.*.failed) {
        state.loaded.failed = true;
    }
}

export fn animation_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        // ozz::io::MemoryStream stream;
        // stream.Write(response->data.ptr, response->data.size);
        // stream.Seek(0, ozz::io::Stream::kSet);
        // ozz::io::IArchive archive(&stream);
        // if (archive.TestTag<ozz::animation::Animation>()) {
        //     archive >> state.ozz->animation;
        //     state.loaded.animation = true;
        // }
        // else {
        //     state.loaded.failed = true;
        // }
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
