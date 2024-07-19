//------------------------------------------------------------------------------
//  ozz-skin-sapp.c
//
//  Ozz-animation with GPU skinning.
//
//  https://guillaumeblanc.github.io/ozz-animation/
//
//  Joint palette data for vertex skinning is uploaded each frame to a dynamic
//  RGBA32F texture and sampled in the vertex shader to perform weighted
//  skinning with up to 4 influence joints per vertex.
//
//  Character instance matrices are stored in a vertex buffer.
//
//  Together this enables rendering many independently animated and positioned
//  characters in a single draw call via hardware instancing.
//------------------------------------------------------------------------------
const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const simgui = sokol.imgui;
const util_camera = @import("util_camera");

// #include "imgui.h"
// #define SOKOL_IMGUI_IMPL
// #include "sokol_imgui.h"
// #define SOKOL_GFX_IMGUI_IMPL
// #include "sokol_gfx_imgui.h"
//
// #define HANDMADE_MATH_IMPLEMENTATION
// #define HANDMADE_MATH_NO_SSE
// #include "HandmadeMath.h"

const fileutil = @import("fileutil");
const shader = @import("ozz-skin-sapp.glsl.zig");
const ozz_wrap = @import("ozz_wrap.zig");

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
// #include "ozz/util/mesh.h"
//
// #include <memory>   // std::unique_ptr, std::make_unique
// #include <cmath>    // fmodf

// the upper limit for joint palette size is 256 (because the mesh joint indices
// are stored in packed byte-size vertex formats), but the example mesh only needs less than 64
const MAX_JOINTS = 64;

// this defines the size of the instance-buffer and height of the joint-texture
const MAX_INSTANCES = 512;

// // wrapper struct for managed ozz-animation C++ objects, must be deleted
// // before shutdown, otherwise ozz-animation will report a memory leak
// typedef struct {
//     ozz::animation::Skeleton skeleton;
//     ozz::animation::Animation animation;
//     ozz::vector<uint16_t> joint_remaps;
//     ozz::vector<ozz::math::Float4x4> mesh_inverse_bindposes;
//     ozz::vector<ozz::math::SoaTransform> local_matrices;
//     ozz::vector<ozz::math::Float4x4> model_matrices;
//     ozz::animation::SamplingCache cache;
// } ozz_t;

// a skinned-mesh vertex, we don't need the texcoords and tangent
// in our example renderer so we just drop them. Normals, joint indices
// and joint weights are packed into BYTE4N and UBYTE4N
//
// NOTE: joint indices are packed as UBYTE4N and not UBYTE4 because of
// D3D11 compatibility (see "A NOTE ON PORTABLE PACKED VERTEX FORMATS" in sokol_gfx.h)
const Vertex = struct {
    position: [3]f32,
    normal: u32,
    joint_indices: u32,
    joint_weights: u32,
};

// per-instance data for hardware-instanced rendering includes the
// transposed 4x3 model-to-world matrix, and information where the
// joint palette is found in the joint texture
const Instance = struct {
    xxxx: [4]f32 = .{ 0, 0, 0, 0 },
    yyyy: [4]f32 = .{ 0, 0, 0, 0 },
    zzzz: [4]f32 = .{ 0, 0, 0, 0 },
    joint_uv: [2]f32 = .{ 0, 0 },
};

const state = struct {
    var ozz: ?*anyopaque = null;
    var pass_action = sg.PassAction{};
    var pip = sg.Pipeline{};
    var joint_texture = sg.Image{};
    var smp = sg.Sampler{};
    var bind = sg.Bindings{};
    // current number of character instances
    var num_instances: u32 = 0;
    var num_triangle_indices: u32 = 0;
    // number of joints in the skeleton
    var num_skeleton_joints: i32 = 0;
    // number of joints actually used by skinned mesh
    var num_skin_joints: i32 = 0;
    // in number of pixels
    var joint_texture_width: i32 = 0;
    // in number of pixels
    var joint_texture_height: i32 = 0;
    // in number of floats
    var joint_texture_pitch: i32 = 0;
    var camera = util_camera.Camera{};
    var draw_enabled = false;
    const loaded = struct {
        var skeleton = false;
        var animation = false;
        var mesh = false;
        var failed = false;
    };
    const time = struct {
        var frame_time_ms: f64 = 0;
        var frame_time_sec: f64 = 0;
        var abs_time_sec: f64 = 0;
        var anim_eval_time: u64 = 0;
        var factor: f32 = 0;
        var paused = false;
    };
    const ui = struct {
        //         sgimgui_t sgimgui;
        var joint_texture_shown = false;
        var joint_texture_scale: i32 = 0;
        var joint_texture = simgui.Image{};
    };
};

// IO buffers (we know the max file sizes upfront)
var skel_io_buffer = [1]u8{0} ** (32 * 1024);
var anim_io_buffer = [1]u8{0} ** (96 * 1024);
var mesh_io_buffer = [1]u8{0} ** (3 * 1024 * 1024);

// instance data buffer;
var instance_data = [1]Instance{.{}} ** MAX_INSTANCES;

// joint-matrix upload buffer, each joint consists of transposed 4x3 matrix
// static float joint_upload_buffer[MAX_INSTANCES][MAX_JOINTS][3][4];

export fn init() void {
    state.ozz = ozz_wrap.OZZ_init();
    state.num_instances = 1;
    state.draw_enabled = true;
    state.time.factor = 1.0;
    state.ui.joint_texture_scale = 4;

    // setup sokol-gfx
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });
    // setup sokol-gl
    sokol.gl.setup(.{
        .sample_count = sokol.app.sampleCount(),
        .logger = .{ .func = sokol.log.func },
    });

    // setup sokol-time
    sokol.time.setup();

    // setup sokol-fetch
    sokol.fetch.setup(.{
        .max_requests = 3,
        .num_channels = 1,
        .num_lanes = 3,
        .logger = .{ .func = sokol.log.func },
    });

    // setup sokol-imgui
    simgui.setup(.{
        .logger = .{ .func = sokol.log.func },
    });
    //     sgimgui_desc_t sgimgui_desc = { };
    //     sgimgui_init(&state.ui.sgimgui, &sgimgui_desc);

    // initialize pass action for default-pass
    state.pass_action.colors[0].load_action = .CLEAR;
    state.pass_action.colors[0].clear_value = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 1.0 };

    // initialize camera controller
    state.camera = util_camera.Camera.init(.{
        .min_dist = 2.0,
        .max_dist = 40.0,
        .center = .{ .x = 0, .y = 1.1, .z = 0 },
        .distance = 3.0,
        .latitude = 20.0,
        .longitude = 20.0,
    });

    // vertex-skinning shader and pipeline object for 3d rendering, note
    // the hardware-instanced vertex layout
    var pip_desc = sg.PipelineDesc{
        .shader = sg.makeShader(shader.skinnedShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        // ozz mesh data appears to have counter-clock-wise face winding
        .face_winding = .CCW,
        .cull_mode = .BACK,
        .depth = .{
            .write_enabled = true,
            .compare = .LESS_EQUAL,
        },
    };
    pip_desc.layout.buffers[0].stride = @sizeOf(Vertex);
    pip_desc.layout.buffers[1].stride = @sizeOf(Instance);
    pip_desc.layout.buffers[1].step_func = .PER_INSTANCE;
    pip_desc.layout.attrs[shader.ATTR_vs_position].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_normal].format = .BYTE4N;
    pip_desc.layout.attrs[shader.ATTR_vs_jindices].format = .UBYTE4N;
    pip_desc.layout.attrs[shader.ATTR_vs_jweights].format = .UBYTE4N;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_xxxx].format = .FLOAT4;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_xxxx].buffer_index = 1;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_yyyy].format = .FLOAT4;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_yyyy].buffer_index = 1;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_zzzz].format = .FLOAT4;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_zzzz].buffer_index = 1;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_joint_uv].format = .FLOAT2;
    pip_desc.layout.attrs[shader.ATTR_vs_inst_joint_uv].buffer_index = 1;
    state.pip = sg.makePipeline(pip_desc);

    // create a dynamic joint-palette texture and sampler
    state.joint_texture_width = MAX_JOINTS * 3;
    state.joint_texture_height = MAX_INSTANCES;
    state.joint_texture_pitch = state.joint_texture_width * 4;
    state.joint_texture = sg.makeImage(.{
        .width = state.joint_texture_width,
        .height = state.joint_texture_height,
        .num_mipmaps = 1,
        .pixel_format = .RGBA32F,
        .usage = .STREAM,
    });
    state.bind.vs.images[shader.SLOT_joint_tex] = state.joint_texture;

    state.smp = sg.makeSampler(.{
        .min_filter = .NEAREST,
        .mag_filter = .NEAREST,
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
    });
    state.bind.vs.samplers[shader.SLOT_smp] = state.smp;

    // create an sokol-imgui wrapper for the joint texture
    state.ui.joint_texture = simgui.makeImage(.{
        .image = state.joint_texture,
        .sampler = state.smp,
    });

    // create a static instance-data buffer, in this demo, character instances
    // don't move around and also are not clipped against the view volume,
    // so we can just initialize a static instance data buffer upfront
    init_instance_data();
    state.bind.vertex_buffers[1] = sg.makeBuffer(.{
        .type = .VERTEXBUFFER,
        .data = sg.asRange(&instance_data),
    });

    _ = sokol.fetch.send(.{
        .path = "sapp/data/ozz/ozz_skin_skeleton.ozz",
        .callback = skel_data_loaded,
        .buffer = sokol.fetch.asRange(&skel_io_buffer),
    });
    _ = sokol.fetch.send(.{
        .path = "sapp/data/ozz/ozz_skin_animation.ozz",
        .callback = anim_data_loaded,
        .buffer = sokol.fetch.asRange(&anim_io_buffer),
    });
    _ = sokol.fetch.send(.{
        .path = "sapp/data/ozz/ozz_skin_mesh.ozz",
        .callback = mesh_data_loaded,
        .buffer = sokol.fetch.asRange(&mesh_io_buffer),
    });
}

// initialize the static instance data, since the character instances don't
// move around or are clipped against the view volume in this demo, the instance
// data is initialized once and lives in an immutable instance buffer
fn init_instance_data() void {
    //     assert((state.joint_texture_width > 0) && (state.joint_texture_height > 0));

    // initialize the character instance model-to-world matrices
    {
        var i: usize = 0;
        var x: f32 = 0;
        var y: f32 = 0;
        var dx: f32 = 0;
        var dy: f32 = 0;
        while (i < MAX_INSTANCES) : ({
            i += 1;
            x += dx;
            y += dy;
        }) {
            const inst = &instance_data[i];

            // a 3x4 transposed model-to-world matrix (only the x/z position is set)
            inst.xxxx[0] = 1.0;
            inst.xxxx[1] = 0.0;
            inst.xxxx[2] = 0.0;
            inst.xxxx[3] = x * 1.5;
            inst.yyyy[0] = 0.0;
            inst.yyyy[1] = 1.0;
            inst.yyyy[2] = 0.0;
            inst.yyyy[3] = 0.0;
            inst.zzzz[0] = 0.0;
            inst.zzzz[1] = 0.0;
            inst.zzzz[2] = 1.0;
            inst.zzzz[3] = y * 1.5;

            // at a corner?
            if (@abs(x) == @abs(y)) {
                if (x >= 0) {
                    // top-right corner: start a new ring
                    if (y >= 0) {
                        x += 1;
                        y += 1;
                        dx = 0;
                        dy = -1;
                    }
                    // bottom-right corner
                    else {
                        dx = -1;
                        dy = 0;
                    }
                } else {
                    // top-left corner
                    if (y >= 0) {
                        dx = 1;
                        dy = 0;
                    }
                    // bottom-left corner
                    else {
                        dx = 0;
                        dy = 1;
                    }
                }
            }
        }
    }

    // the skin_info vertex component contains information about where to find
    // the joint palette for this character instance in the joint texture
    const half_pixel_x = 0.5 / @as(f32, @floatFromInt(state.joint_texture_width));
    const half_pixel_y = 0.5 / @as(f32, @floatFromInt(state.joint_texture_height));
    for (0..MAX_INSTANCES) |i| {
        const inst = &instance_data[i];
        inst.joint_uv[0] = half_pixel_x;
        inst.joint_uv[1] = half_pixel_y + (@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(state.joint_texture_height)));
    }
}

// compute skinning matrices, and upload into joint texture
fn update_joint_texture() void {
    //
    //     uint64_t start_time = stm_now();
    //     const float anim_duration = state.ozz->animation.duration();
    //     for (int instance = 0; instance < state.num_instances; instance++) {
    //
    //         // each character instance evaluates its own animation
    //         const float anim_ratio = fmodf(((float)state.time.abs_time_sec + (instance*0.1f)) / anim_duration, 1.0f);
    //
    //         // sample animation
    //         // NOTE: using one cache per instance versus one cache per animation
    //         // makes a small difference, but not much
    //         ozz::animation::SamplingJob sampling_job;
    //         sampling_job.animation = &state.ozz->animation;
    //         sampling_job.cache = &state.ozz->cache;
    //         sampling_job.ratio = anim_ratio;
    //         sampling_job.output = make_span(state.ozz->local_matrices);
    //         sampling_job.Run();
    //
    //         // convert joint matrices from local to model space
    //         ozz::animation::LocalToModelJob ltm_job;
    //         ltm_job.skeleton = &state.ozz->skeleton;
    //         ltm_job.input = make_span(state.ozz->local_matrices);
    //         ltm_job.output = make_span(state.ozz->model_matrices);
    //         ltm_job.Run();
    //
    //         // compute skinning matrices and write to joint texture upload buffer
    //         for (int i = 0; i < state.num_skin_joints; i++) {
    //             ozz::math::Float4x4 skin_matrix = state.ozz->model_matrices[state.ozz->joint_remaps[i]] * state.ozz->mesh_inverse_bindposes[i];
    //             const ozz::math::SimdFloat4& c0 = skin_matrix.cols[0];
    //             const ozz::math::SimdFloat4& c1 = skin_matrix.cols[1];
    //             const ozz::math::SimdFloat4& c2 = skin_matrix.cols[2];
    //             const ozz::math::SimdFloat4& c3 = skin_matrix.cols[3];
    //
    //             float* ptr = &joint_upload_buffer[instance][i][0][0];
    //             *ptr++ = ozz::math::GetX(c0); *ptr++ = ozz::math::GetX(c1); *ptr++ = ozz::math::GetX(c2); *ptr++ = ozz::math::GetX(c3);
    //             *ptr++ = ozz::math::GetY(c0); *ptr++ = ozz::math::GetY(c1); *ptr++ = ozz::math::GetY(c2); *ptr++ = ozz::math::GetY(c3);
    //             *ptr++ = ozz::math::GetZ(c0); *ptr++ = ozz::math::GetZ(c1); *ptr++ = ozz::math::GetZ(c2); *ptr++ = ozz::math::GetZ(c3);
    //         }
    //     }
    //     state.time.anim_eval_time = stm_since(start_time);
    //
    //     sg_image_data img_data = { };
    //     // FIXME: upload partial texture? (needs sokol-gfx fixes)
    //     img_data.subimage[0][0] = SG_RANGE(joint_upload_buffer);
    //     sg_update_image(state.joint_texture, img_data);
}

export fn frame() void {
    sokol.fetch.dowork();

    const fb_width = sokol.app.width();
    const fb_height = sokol.app.height();
    state.time.frame_time_sec = sokol.app.frameDuration();
    state.time.frame_time_ms = sokol.app.frameDuration() * 1000.0;
    if (!state.time.paused) {
        state.time.abs_time_sec += state.time.frame_time_sec * state.time.factor;
    }
    state.camera.update(fb_width, fb_height);
    simgui.newFrame(.{
        .width = fb_width,
        .height = fb_height,
        .delta_time = state.time.frame_time_sec,
        .dpi_scale = sokol.app.dpiScale(),
    });
    draw_ui();

    sokol.gl.defaults();
    sokol.gl.matrixModeProjection();
    sokol.gl.loadMatrix(&state.camera.proj.m[0]);
    sokol.gl.matrixModeModelview();
    sokol.gl.loadMatrix(&state.camera.view.m[0]);
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
    sokol.gl.end();

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sokol.gl.draw();

    if (state.loaded.animation and state.loaded.skeleton and state.loaded.mesh) {
        update_joint_texture();

        sg.applyPipeline(state.pip);
        sg.applyBindings(state.bind);
        sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(&.{
            .view_proj = state.camera.view_proj,
            .joint_pixel_width = 1.0 / @as(f32, @floatFromInt(state.joint_texture_width)),
        }));
        if (state.draw_enabled) {
            sg.draw(0, state.num_triangle_indices, state.num_instances);
        }
    }
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
    //     sgimgui_discard(&state.ui.sgimgui);
    simgui.shutdown();
    sokol.fetch.shutdown();
    sg.shutdown();

    if (state.ozz) |ozz| {
        ozz_wrap.OZZ_shutdown(ozz);
    }
}

fn draw_ui() void {
    //     if (ImGui::BeginMainMenuBar()) {
    //         sgimgui_draw_menu(&state.ui.sgimgui, "sokol-gfx");
    //         ImGui::EndMainMenuBar();
    //     }
    //     sgimgui_draw(&state.ui.sgimgui);
    //     ImGui::SetNextWindowPos({ 20, 20 }, ImGuiCond_Once);
    //     ImGui::SetNextWindowSize({ 220, 150 }, ImGuiCond_Once);
    //     ImGui::SetNextWindowBgAlpha(0.35f);
    //     if (ImGui::Begin("Controls", nullptr, ImGuiWindowFlags_NoDecoration|ImGuiWindowFlags_AlwaysAutoResize)) {
    //         if (state.loaded.failed) {
    //             ImGui::Text("Failed loading character data!");
    //         }
    //         else {
    //             if (ImGui::SliderInt("Num Instances", &state.num_instances, 1, MAX_INSTANCES)) {
    //                 float dist_step = (state.camera.max_dist - state.camera.min_dist) / MAX_INSTANCES;
    //                 state.camera.distance = state.camera.min_dist + dist_step * state.num_instances;
    //             }
    //             ImGui::Checkbox("Enable Mesh Drawing", &state.draw_enabled);
    //             ImGui::Text("Frame Time: %.3fms\n", state.time.frame_time_ms);
    //             ImGui::Text("Anim Eval Time: %.3fms\n", stm_ms(state.time.anim_eval_time));
    //             ImGui::Text("Num Triangles: %d\n", (state.num_triangle_indices/3) * state.num_instances);
    //             ImGui::Text("Num Animated Joints: %d\n", state.num_skeleton_joints * state.num_instances);
    //             ImGui::Text("Num Skinning Joints: %d\n", state.num_skin_joints * state.num_instances);
    //             ImGui::Separator();
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
    //             ImGui::Separator();
    //             if (ImGui::Button("Toggle Joint Texture")) {
    //                 state.ui.joint_texture_shown = !state.ui.joint_texture_shown;
    //             }
    //         }
    //     }
    //     if (state.ui.joint_texture_shown) {
    //         ImGui::SetNextWindowPos({ 20, 300 }, ImGuiCond_Once);
    //         ImGui::SetNextWindowSize({ 600, 300 }, ImGuiCond_Once);
    //         if (ImGui::Begin("Joint Texture", &state.ui.joint_texture_shown)) {
    //             ImGui::InputInt("##scale", &state.ui.joint_texture_scale);
    //             ImGui::SameLine();
    //             if (ImGui::Button("1x")) { state.ui.joint_texture_scale = 1; }
    //             ImGui::SameLine();
    //             if (ImGui::Button("2x")) { state.ui.joint_texture_scale = 2; }
    //             ImGui::SameLine();
    //             if (ImGui::Button("4x")) { state.ui.joint_texture_scale = 4; }
    //             ImGui::BeginChild("##frame", {0,0}, true, ImGuiWindowFlags_HorizontalScrollbar);
    //             ImGui::Image(simgui_imtextureid(state.ui.joint_texture),
    //                 { (float)(state.joint_texture_width * state.ui.joint_texture_scale), (float)(state.joint_texture_height * state.ui.joint_texture_scale) },
    //                 { 0.0f, 0.0f },
    //                 { 1.0f, 1.0f });
    //             ImGui::EndChild();
    //         }
    //         ImGui::End();
    //     }
    //     ImGui::End();
}

// FIXME: all loading code is much less efficient than it should be!
export fn skel_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (state.ozz) |ozz| {
            if (ozz_wrap.OZZ_load_skeleton(ozz, response.*.data.ptr, response.*.data.size)) {
                state.loaded.skeleton = true;
            } else {
                state.loaded.failed = true;
            }
        }
    } else if (response.*.failed) {
        state.loaded.failed = true;
    }
}

export fn anim_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (state.ozz) |ozz| {
            if (ozz_wrap.OZZ_load_animation(ozz, response.*.data.ptr, response.*.data.size)) {
                state.loaded.animation = true;
            } else {
                state.loaded.failed = true;
            }
        }
    } else if (response.*.failed) {
        state.loaded.failed = true;
    }
}

// static uint32_t pack_u32(uint8_t x, uint8_t y, uint8_t z, uint8_t w) {
//     return (uint32_t)(((uint32_t)w<<24)|((uint32_t)z<<16)|((uint32_t)y<<8)|x);
// }

// static uint32_t pack_f4_byte4n(float x, float y, float z, float w) {
//     int8_t x8 = (int8_t) (x * 127.0f);
//     int8_t y8 = (int8_t) (y * 127.0f);
//     int8_t z8 = (int8_t) (z * 127.0f);
//     int8_t w8 = (int8_t) (w * 127.0f);
//     return pack_u32((uint8_t)x8, (uint8_t)y8, (uint8_t)z8, (uint8_t)w8);
// }

// static uint32_t pack_f4_ubyte4n(float x, float y, float z, float w) {
//     uint8_t x8 = (uint8_t) (x * 255.0f);
//     uint8_t y8 = (uint8_t) (y * 255.0f);
//     uint8_t z8 = (uint8_t) (z * 255.0f);
//     uint8_t w8 = (uint8_t) (w * 255.0f);
//     return pack_u32(x8, y8, z8, w8);
// }

export fn mesh_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (state.ozz) |ozz| {
            if (ozz_wrap.OZZ_load_mesh(ozz, response.*.data.ptr, response.*.data.size)) {
                state.loaded.mesh = true;
            } else {
                state.loaded.failed = true;
            }
        }
        //         ozz::io::MemoryStream stream;
        //         stream.Write(response->data.ptr, response->data.size);
        //         stream.Seek(0, ozz::io::Stream::kSet);
        //
        //         ozz::vector<ozz::sample::Mesh> meshes;
        //         ozz::io::IArchive archive(&stream);
        //         while (archive.TestTag<ozz::sample::Mesh>()) {
        //             meshes.resize(meshes.size() + 1);
        //             archive >> meshes.back();
        //         }
        //         // assume one mesh and one submesh
        //         assert((meshes.size() == 1) && (meshes[0].parts.size() == 1));
        //         state.loaded.mesh = true;
        //         state.num_skin_joints = meshes[0].num_joints();
        //         state.num_triangle_indices = (int)meshes[0].triangle_index_count();
        //         state.ozz->joint_remaps = std::move(meshes[0].joint_remaps);
        //         state.ozz->mesh_inverse_bindposes = std::move(meshes[0].inverse_bind_poses);
        //
        //         // convert mesh data into packed vertices
        //         size_t num_vertices = (meshes[0].parts[0].positions.size() / 3);
        //         assert(meshes[0].parts[0].normals.size() == (num_vertices * 3));
        //         assert(meshes[0].parts[0].joint_indices.size() == (num_vertices * 4));
        //         assert(meshes[0].parts[0].joint_weights.size() == (num_vertices * 3));
        //         const float* positions = &meshes[0].parts[0].positions[0];
        //         const float* normals = &meshes[0].parts[0].normals[0];
        //         const uint16_t* joint_indices = &meshes[0].parts[0].joint_indices[0];
        //         const float* joint_weights = &meshes[0].parts[0].joint_weights[0];
        //         vertex_t* vertices = (vertex_t*) calloc(num_vertices, sizeof(vertex_t));
        //         for (int i = 0; i < (int)num_vertices; i++) {
        //             vertex_t* v = &vertices[i];
        //             v->position[0] = positions[i * 3 + 0];
        //             v->position[1] = positions[i * 3 + 1];
        //             v->position[2] = positions[i * 3 + 2];
        //             const float nx = normals[i * 3 + 0];
        //             const float ny = normals[i * 3 + 1];
        //             const float nz = normals[i * 3 + 2];
        //             v->normal = pack_f4_byte4n(nx, ny, nz, 0.0f);
        //             const uint8_t ji0 = (uint8_t) joint_indices[i * 4 + 0];
        //             const uint8_t ji1 = (uint8_t) joint_indices[i * 4 + 1];
        //             const uint8_t ji2 = (uint8_t) joint_indices[i * 4 + 2];
        //             const uint8_t ji3 = (uint8_t) joint_indices[i * 4 + 3];
        //             v->joint_indices = pack_u32(ji0, ji1, ji2, ji3);
        //             const float jw0 = joint_weights[i * 3 + 0];
        //             const float jw1 = joint_weights[i * 3 + 1];
        //             const float jw2 = joint_weights[i * 3 + 2];
        //             const float jw3 = 1.0f - (jw0 + jw1 + jw2);
        //             v->joint_weights = pack_f4_ubyte4n(jw0, jw1, jw2, jw3);
        //         }
        //
        //         // create vertex- and index-buffer
        //         sg_buffer_desc vbuf_desc = { };
        //         vbuf_desc.type = SG_BUFFERTYPE_VERTEXBUFFER;
        //         vbuf_desc.data.ptr = vertices;
        //         vbuf_desc.data.size = num_vertices * sizeof(vertex_t);
        //         state.bind.vertex_buffers[0] = sg_make_buffer(&vbuf_desc);
        //         free(vertices); vertices = nullptr;
        //
        //         sg_buffer_desc ibuf_desc = { };
        //         ibuf_desc.type = SG_BUFFERTYPE_INDEXBUFFER;
        //         ibuf_desc.data.ptr = &meshes[0].triangle_indices[0];
        //         ibuf_desc.data.size = state.num_triangle_indices * sizeof(uint16_t);
        //         state.bind.index_buffer = sg_make_buffer(&ibuf_desc);
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
        .window_title = "ozz-skin-sapp.cc",
        .icon = .{ .sokol_default = true },
        .logger = .{ .func = sokol.log.func },
    });
}
