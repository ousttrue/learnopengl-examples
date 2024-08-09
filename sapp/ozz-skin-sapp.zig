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
const shader = @import("ozz-skin-sapp.glsl.zig");
const ozz_wrap = @import("ozz_wrap.zig");
// const simgui = sokol.imgui;
const util_camera = @import("util_camera");

// the upper limit for joint palette size is 256 (because the mesh joint indices
// are stored in packed byte-size vertex formats), but the example mesh only needs less than 64
const MAX_JOINTS = 64;

// this defines the size of the instance-buffer and height of the joint-texture
const MAX_INSTANCES = 512;

const Vertex = extern struct {
    position: [3]f32,
    normal: u32,
    joint_indices: u32,
    joint_weights: u32,
};

// per-instance data for hardware-instanced rendering includes the
// transposed 4x3 model-to-world matrix, and information where the
// joint palette is found in the joint texture
const Instance = struct {
    xxxx: [4]f32,
    yyyy: [4]f32,
    zzzz: [4]f32,
    joint_uv: [2]f32,
};

const state = struct {
    var ozz: *anyopaque = undefined;

    var pass_action = sg.PassAction{};
    var pip = sg.Pipeline{};
    var joint_texture = sg.Image{};
    var smp = sg.Sampler{};
    var bind = sg.Bindings{};

    var num_instances: u32 = 1; // current number of character instances
    var num_vertices: u32 = 0;
    var num_triangle_indices: u32 = 0;
    var joint_texture_width: c_int = 0; // in number of pixels
    var joint_texture_height: c_int = 0; // in number of pixels
    var joint_texture_pitch: c_int = 0; // in number of floats
    var camera: util_camera.Camera = .{};
    var draw_enabled: bool = false;
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
        //         uint64_t anim_eval_time;
        var factor: f32 = 1.0;
        var paused = false;
    };
    const ui = struct {
        //         sgimgui_t sgimgui;
        //         bool joint_texture_shown;
        var joint_texture_scale: i32 = 4;
        //         simgui_image_t joint_texture;
    };
};

// IO buffers (we know the max file sizes upfront)
var skel_io_buffer: [32 * 1024]u8 = undefined;
var anim_io_buffer: [96 * 1024]u8 = undefined;
var mesh_io_buffer: [3 * 1024 * 1024]u8 = undefined;

// instance data buffer;
var instance_data: [MAX_INSTANCES]Instance = undefined;

// joint-matrix upload buffer, each joint consists of transposed 4x3 matrix
// static float joint_upload_buffer[MAX_INSTANCES][MAX_JOINTS][3][4];

export fn init() void {
    state.ozz = ozz_wrap.OZZ_init();
    // setup sokol-gfx
    sg.setup(.{
        .environment = sokol.glue.environment(),
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
    // var imdesc = simgui.Desc{};
    // imdesc.logger.func = sokol.log.func;
    // simgui.setup(&imdesc);
    //     sgimgui_desc_t sgimgui_desc = { };
    //     sgimgui_init(&state.ui.sgimgui, &sgimgui_desc);

    // initialize pass action for default-pass
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 1.0 },
    };

    // initialize camera controller
    state.camera = util_camera.Camera.init(.{
        .min_dist = 2.0,
        .max_dist = 40.0,
        .center = .{ .x = 0, .y = 1.0, .z = 0 },
        .distance = 3.0,
        .latitude = 20.0,
        .longitude = 20.0,
    });

    // vertex-skinning shader and pipeline object for 3d rendering, note the hardware-instanced vertex layout
    var pip_desc = sg.PipelineDesc{
        .shader = sg.makeShader(shader.skinnedShaderDesc(sg.queryBackend())),
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
    pip_desc.index_type = .UINT16;
    // ozz mesh data appears to have counter-clock-wise face winding
    pip_desc.face_winding = .CCW;
    pip_desc.cull_mode = .BACK;
    pip_desc.depth.write_enabled = true;
    pip_desc.depth.compare = .LESS_EQUAL;
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
    // simgui_image_desc_t simgui_img_desc = { };
    // simgui_img_desc.image = state.joint_texture;
    // simgui_img_desc.sampler = state.smp;
    // state.ui.joint_texture = simgui_make_image(&simgui_img_desc);

    // create a static instance-data buffer, in this demo, character instances
    // don't move around and also are not clipped against the view volume,
    // so we can just initialize a static instance data buffer upfront
    init_instance_data();
    state.bind.vertex_buffers[1] = sg.makeBuffer(.{
        .type = .VERTEXBUFFER,
        .data = sg.asRange(&instance_data),
    });

    // start loading data
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
        var x: c_int = 0;
        var y: c_int = 0;
        var dx: c_int = 0;
        var dy: c_int = 0;
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
            inst.xxxx[3] = @as(f32, @floatFromInt(x)) * 1.5;
            inst.yyyy[0] = 0.0;
            inst.yyyy[1] = 1.0;
            inst.yyyy[2] = 0.0;
            inst.yyyy[3] = 0.0;
            inst.zzzz[0] = 0.0;
            inst.zzzz[1] = 0.0;
            inst.zzzz[2] = 1.0;
            inst.zzzz[3] = @as(f32, @floatFromInt(y)) * 1.5;

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
    //     simgui_new_frame({ fb_width, fb_height, state.time.frame_time_sec, sapp_dpi_scale() });
    //     draw_ui();

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });

    if (state.loaded.animation and state.loaded.skeleton and state.loaded.mesh) {
        update_joint_texture();

        const vs_params = shader.VsParams{
            .view_proj = state.camera.view_proj.m,
            .joint_pixel_width = 1.0 / @as(f32, @floatFromInt(state.joint_texture_width)),
        };
        sg.applyPipeline(state.pip);
        sg.applyBindings(state.bind);
        sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(&vs_params));
        if (state.draw_enabled) {
            sg.draw(0, state.num_triangle_indices, state.num_instances);
        }
    }
    //     simgui_render();
    sg.endPass();
    sg.commit();
}

export fn input(ev: [*c]const sokol.app.Event) void {
    // if (simgui_handle_event(ev)) {
    //     return;
    // }
    state.camera.handleEvent(ev);
}

export fn cleanup() void {
    //     sgimgui_discard(&state.ui.sgimgui);
    //     simgui_shutdown();
    sokol.fetch.shutdown();
    sg.shutdown();

    // free C++ objects early, otherwise ozz-animation complains about memory leaks
    ozz_wrap.OZZ_shutdown(state.ozz);
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
        std.debug.print("skel_data_loaded {} bytes\n", .{response.*.data.size});
        if (ozz_wrap.OZZ_load_skeleton(state.ozz, response.*.data.ptr, response.*.data.size)) {
            state.loaded.skeleton = true;
        } else {
            state.loaded.failed = true;
        }
    } else if (response.*.failed) {
        std.debug.print("skel_data_loaded fail\n", .{});
        state.loaded.failed = true;
    } else {
        unreachable;
    }
}

export fn anim_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        std.debug.print("anim_data_loaded {} bytes\n", .{response.*.data.size});
        if (ozz_wrap.OZZ_load_animation(state.ozz, response.*.data.ptr, response.*.data.size)) {
            state.loaded.animation = true;
        } else {
            state.loaded.failed = true;
        }
    } else if (response.*.failed) {
        std.debug.print("anim_data_loaded fail\n", .{});
        state.loaded.failed = true;
    } else {
        unreachable;
    }
}

export fn mesh_data_loaded(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        std.debug.print("mesh_data_loaded {} bytes\n", .{response.*.data.size});
        var vertices: *anyopaque = undefined;
        var indices: *anyopaque = undefined;
        if (ozz_wrap.OZZ_load_mesh(
            state.ozz,
            response.*.data.ptr,
            response.*.data.size,
            &vertices,
            &state.num_vertices,
            &indices,
            &state.num_triangle_indices,
        )) {
            defer ozz_wrap.OZZ_free(vertices);
            defer ozz_wrap.OZZ_free(indices);
            std.debug.print("vert({}): {}, idx: {}\n", .{
                @sizeOf(Vertex),
                state.num_vertices,
                state.num_triangle_indices,
            });
            std.debug.assert(state.num_vertices > 0);
            std.debug.assert(state.num_triangle_indices > 0);
            std.debug.assert(@sizeOf(Vertex) == 24);

            // create vertex- and index-buffer
            var vbuf_desc = sg.BufferDesc{};
            vbuf_desc.type = .VERTEXBUFFER;
            vbuf_desc.data.ptr = vertices;
            vbuf_desc.data.size = state.num_vertices * @sizeOf(Vertex);
            state.bind.vertex_buffers[0] = sg.makeBuffer(vbuf_desc);

            var ibuf_desc = sg.BufferDesc{};
            ibuf_desc.type = .INDEXBUFFER;
            ibuf_desc.data.ptr = indices;
            ibuf_desc.data.size = state.num_triangle_indices * @sizeOf(u16);
            state.bind.index_buffer = sg.makeBuffer(ibuf_desc);

            state.loaded.mesh = true;
        } else {
            state.loaded.failed = true;
        }
    } else if (response.*.failed) {
        std.debug.print("mesh_data_loaded fail\n", .{});
        state.loaded.failed = true;
    } else {
        unreachable;
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
