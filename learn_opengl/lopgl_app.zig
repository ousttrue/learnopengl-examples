const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const OrbitalCamera = @import("lopgl_app_orbital.zig").OrbitalCamera;
const szmath = @import("szmath");
const Vec2 = szmath.Vec2;
const Vec3 = szmath.Vec3;
const Mat4 = szmath.Mat4;

//     TODO:
//         - add asserts to check setup has been called
//         - add default values for all structs
//         - use canary?
//         - improve structure and add/update documentation
//         - add support for obj's with multiple materials
//         - add define to select functionality and reduce binary size
//         - use get/set to configure cameras

// response fail callback function signature
const FailCallback = fn () void;

// typedef struct lopgl_obj_response_t {
//     uint32_t _start_canary;
//     fastObjMesh* mesh;
//     void* user_data_ptr;
//     uint32_t _end_canary;
// } lopgl_obj_response_t;

// typedef void(*lopgl_obj_request_callback_t)(lopgl_obj_response_t*);

// /* request parameters passed to lopgl_load_image() */
// typedef struct lopgl_image_request_t {
//     uint32_t _start_canary;
//     const char* path;                       /* filesystem path or HTTP URL (required) */
//     sg_image img_id;
//     sg_wrap wrap_u;
//     sg_wrap wrap_v;
//     sfetch_range_t buffer;
//     void* buffer_ptr;                       /* buffer pointer where data will be loaded into */
//     uint32_t buffer_size;                   /* buffer size in number of bytes */
//     lopgl_fail_callback_t fail_callback;    /* response callback function pointer (required) */
//     uint32_t _end_canary;
// } lopgl_image_request_t;

// /* request parameters passed to sfetch_send() */
// typedef struct lopgl_obj_request_t {
//     uint32_t _start_canary;
//     const char* path;                       /* filesystem path or HTTP URL (required) */
//     sfetch_range_t buffer;
//     void* buffer_ptr;                       /* buffer pointer where data will be loaded into */
//     uint32_t buffer_size;                   /* buffer size in number of bytes */
//     const void* user_data_ptr;              /* pointer to a POD user-data block which will be memcpy'd(!) (optional) */
//     lopgl_obj_request_callback_t callback;
//     lopgl_fail_callback_t fail_callback;    /* response callback function pointer (required) */
//     uint32_t _end_canary;
// } lopgl_obj_request_t;

// typedef struct lopgl_cubemap_request_t {
//     uint32_t _start_canary;
//     const char* path_right;                 /* filesystem path or HTTP URL (required) */
//     const char* path_left;                  /* filesystem path or HTTP URL (required) */
//     const char* path_top;                   /* filesystem path or HTTP URL (required) */
//     const char* path_bottom;                /* filesystem path or HTTP URL (required) */
//     const char* path_front;                 /* filesystem path or HTTP URL (required) */
//     const char* path_back;                  /* filesystem path or HTTP URL (required) */
//     sg_image img_id;
//     sfetch_range_t buffer;
//     uint8_t* buffer_ptr;                       /* buffer pointer where data will be loaded into */
//     uint32_t buffer_offset;                 /* buffer offset in number of bytes */
//     lopgl_fail_callback_t fail_callback;    /* response callback function pointer (required) */
//     uint32_t _end_canary;
// } lopgl_cubemap_request_t;

// typedef struct _cubemap_request_t {
//     sg_image img_id;
//     uint8_t* buffer;
//     int buffer_offset;
//     int fetched_sizes[6];
//     int finished_requests;
//     bool failed;
//     lopgl_fail_callback_t fail_callback;
// } _cubemap_request_t;

const state = struct {
    var orbital_cam = OrbitalCamera{};
    //     struct fp_cam fp_cam;
    var fp_enabled = false;
    var show_help = true;
    var hide_ui = false;
    var first_mouse = true;
    var last_mouse = Vec2{ .x = 0, .y = 0 };
    var time_stamp: u64 = 0;
    var frame_time: u64 = 0;
    //     _cubemap_request_t cubemap_req;
};

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

    state.orbital_cam.desc = .{
        .target = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .pitch = 0.0,
        .heading = 0.0,
        .distance = 6.0,
        .zoom_speed = 0.5,
        .min_dist = 1.0,
        .max_dist = 10.0,
        .min_pitch = -89.0,
        .max_pitch = 89.0,
    };

    //     lopgl_set_fp_cam(&(lopgl_fp_cam_desc_t) {
    //         .position = HMM_V3(0.0f, 0.0f,  6.0f),
    //         .world_up = HMM_V3(0.0f, 1.0f,  0.0f),
    //         .yaw = -90.f,
    //         .pitch = 0.f,
    //         .zoom = 45.f,
    //         .movement_speed = 0.005f,
    //         .aim_speed = 1.f,
    //         .zoom_speed = .1f,
    //         .min_pitch = -89.f,
    //         .max_pitch = 89.f,
    //         .min_zoom = 1.f,
    //         .max_zoom = 45.f
    //     });

}

pub fn update() void {
    sokol.fetch.dowork();

    state.frame_time = sokol.time.laptime(&state.time_stamp);

    if (state.fp_enabled) {
        // update_fp_camera(&state.fp_cam, stm_ms(state.frame_time));
    }
}

pub fn shutdown() void {
    sg.shutdown();
}

pub fn viewMatrix() Mat4 {
    if (state.fp_enabled) {
        unreachable;
        // return view_matrix_fp(&state.fp_cam);
    } else {
        return state.orbital_cam.view_matrix(); //_orbital(&state.orbital_cam);
    }
}

pub fn fovDegree() f32 {
    return 45.0;
}
pub fn fovRadians() f32 {
    return std.math.degreesToRadians(45.0);
}
pub fn cameraPosition() Vec3 {
    if (state.fp_enabled) {
        return state.fp_cam.position;
    } else {
        return state.orbital_cam.position;
    }
}

pub fn cameraDirection() Vec3 {
    if (state.fp_enabled) {
        return state.fp_cam.front;
    } else {
        return state.orbital_cam.target.sub(state.orbital_cam.position).normalized();
    }
}

fn get_mouse_delta(e: [*c]const sokol.app.Event) Vec2 {
    defer state.last_mouse = .{
        .x = e.*.mouse_x,
        .y = e.*.mouse_y,
    };
    if (e.*.type == .MOUSE_MOVE) {
        if (!state.first_mouse) {
            return Vec2{
                .x = e.*.mouse_x - state.last_mouse.x,
                .y = state.last_mouse.y - e.*.mouse_y,
            };
        } else {
            state.first_mouse = false;
        }
    }
    return .{ .x = 0, .y = 0 };
}

pub fn handleInput(e: [*c]const sokol.app.Event) void {
    if (e.*.type == .KEY_DOWN) {
        if (e.*.key_code == .C) {
            state.fp_enabled = !state.fp_enabled;
        } else if (e.*.key_code == .H) {
            state.show_help = !state.show_help;
        } else if (e.*.key_code == .U) {
            state.hide_ui = !state.hide_ui;
        } else if (e.*.key_code == .ESCAPE) {
            sokol.app.requestQuit();
        }
    }

    const mouse_offset = get_mouse_delta(e);

    if (state.fp_enabled) {
        unreachable;
        // handle_input_fp(&state.fp_cam, e, mouse_offset);
    } else {
        state.orbital_cam.handle_input(e, mouse_offset);
    }
}

pub fn uiVisible() bool {
    return !state.hide_ui;
}

pub fn renderHelp() void {
    if (state.hide_ui) {
        return;
    }

    sokol.debugtext.canvas(sokol.app.widthf() * 0.5, sokol.app.heightf() * 0.5);
    sokol.debugtext.origin(0.25, 0.25);
    sokol.debugtext.home();

    if (!state.show_help) {
        sokol.debugtext.color4b(0xff, 0xff, 0xff, 0xaf);
        sokol.debugtext.puts("Show help:\t'H'");
    } else {
        sokol.debugtext.color4b(0x00, 0xff, 0x00, 0xaf);
        sokol.debugtext.puts("Hide help:\t'H'\n\n");
        sokol.debugtext.print("Frame Time:\t{}\n\n", .{sokol.time.ms(state.frame_time)});
        sokol.debugtext.print("Orbital Cam\t[{}]\n", .{@as(u8, if (state.fp_enabled) ' ' else '*')});
        sokol.debugtext.print("yaw, pitch\t[{d:.3}, {d:.3}]\n", .{
            state.orbital_cam.desc.heading,
            state.orbital_cam.desc.pitch,
        });
        sokol.debugtext.print("mouse\t[{d:.3}, {d:.3}]\n", .{ state.last_mouse.x, state.last_mouse.y });
        sokol.debugtext.print("FP Cam\t\t[{}]\n\n", .{@as(u8, if (state.fp_enabled) '*' else ' ')});
        sokol.debugtext.puts("Switch Cam:\t'C'\n\n");

        if (state.fp_enabled) {
            unreachable;
            // sokol.debugtext.puts(help_fp(&state.fp_cam));
        } else {
            sokol.debugtext.puts(state.orbital_cam.help());
        }

        sokol.debugtext.puts("\nExit:\t\t'ESC'");
    }

    sokol.debugtext.draw();
}

pub fn renderGles2Fallback() void {
    //     const sg_pass_action pass_action = {
    //         .colors[0] = { .load_action = SG_LOADACTION_CLEAR, .clear_value = { 1.0f, 0.0f, 0.0f, 1.0f } },
    //     };
    //     sg_begin_pass(&(sg_pass){ .action = pass_action, .swapchain = sglue_swapchain() });
    //
    //     sdtx_canvas(sapp_width()*0.5f, sapp_height()*0.5f);
    //     sdtx_origin(0.25f, 0.25f);
    //     sdtx_home();
    //     sdtx_color4b(0xff, 0xff, 0xff, 0xff);
    //     sdtx_puts("This browser does not support WebGL 2.\n");
    //     sdtx_puts("Try Chrome, Edge or Firefox.");
    //     sdtx_draw();
    //
    //     sg_end_pass();
    //     sg_commit();
}

// typedef struct {
//     sg_image img_id;
//     sg_wrap wrap_u;
//     sg_wrap wrap_v;
//     lopgl_fail_callback_t fail_callback;
// } lopgl_img_request_data;
//
// /* The fetch-callback is called by sokol_fetch.h when the data is loaded,
//    or when an error has occurred.
// */
// static void image_fetch_callback(const sfetch_response_t* response) {
//     lopgl_img_request_data req_data = *(lopgl_img_request_data*)response.user_data;
//
//     if (response.fetched) {
//         /* the file data has been fetched, since we provided a big-enough
//            buffer we can be sure that all data has been loaded here
//         */
//         int img_width, img_height, num_channels;
//         const int desired_channels = 4;
//         stbi_uc* pixels = stbi_load_from_memory(
//             response.data.ptr,
//             (int)response.data.size,
//             &img_width, &img_height,
//             &num_channels, desired_channels);
//         if (pixels) {
//             /* initialize the sokol-gfx texture */
//             sg_init_image(req_data.img_id, &(sg_image_desc){
//                 .width = img_width,
//                 .height = img_height,
//                 /* set pixel_format to RGBA8 for WebGL */
//                 .pixel_format = SG_PIXELFORMAT_RGBA8,
//                 .data.subimage[0][0] = {
//                     .ptr = pixels,
//                     .size = img_width * img_height * desired_channels,
//                 }
//             });
//             stbi_image_free(pixels);
//         }
//     }
//     else if (response.failed) {
//         req_data.fail_callback();
//     }
// }

// typedef struct {
//     fastObjMesh* mesh;
//     lopgl_obj_request_callback_t callback;
//     lopgl_fail_callback_t fail_callback;
//     sfetch_range_t buffer;
//     void* buffer_ptr;
//     uint32_t buffer_size;
//     void* user_data_ptr;
// } lopgl_obj_request_data;

// static void mtl_fetch_callback(const sfetch_response_t* response) {
//     lopgl_obj_request_data req_data = *(lopgl_obj_request_data*)response.user_data;
//
//     if (response.fetched) {
//         fast_obj_mtllib_read(req_data.mesh, response.data.ptr, response.data.size);
//         req_data.callback(&(lopgl_obj_response_t){
//             .mesh = req_data.mesh,
//             .user_data_ptr = req_data.user_data_ptr
//         });
//     }
//     else if (response.failed) {
//         req_data.fail_callback();
//     }
//
//     fast_obj_destroy(req_data.mesh);
// }

// static void obj_fetch_callback(const sfetch_response_t* response) {
//     lopgl_obj_request_data req_data = *(lopgl_obj_request_data*)response.user_data;
//
//     if (response.fetched) {
//         /* the file data has been fetched, since we provided a big-enough
//            buffer we can be sure that all data has been loaded here
//         */
//         req_data.mesh = fast_obj_read(response.data.ptr, response.data.size);
//
//         for (unsigned int i = 0; i < req_data.mesh.mtllib_count; ++i) {
//             sfetch_range_t buffer = req_data.buffer_ptr != NULL ? (sfetch_range_t){req_data.buffer_ptr, req_data.buffer_size} : req_data.buffer;
//             sfetch_send(&(sfetch_request_t){
//                 .path = req_data.mesh.mtllibs[i],
//                 .callback = mtl_fetch_callback,
//                 .buffer = buffer,
//                 .user_data = SFETCH_RANGE(req_data),
//             });
//         }
//     }
//     else if (response.failed) {
//         req_data.fail_callback();
//     }
// }

// void lopgl_load_image(const lopgl_image_request_t* request) {
//     lopgl_img_request_data req_data = {
//         .img_id = request.img_id,
//         .wrap_u = request.wrap_u,
//         .wrap_v = request.wrap_v,
//         .fail_callback = request.fail_callback
//     };
//     sfetch_range_t buffer = request.buffer_ptr != NULL ? (sfetch_range_t){request.buffer_ptr, request.buffer_size} : request.buffer;
//     sfetch_send(&(sfetch_request_t){
//         .path = request.path,
//         .callback = image_fetch_callback,
//         .buffer = buffer,
//         .user_data = SFETCH_RANGE(req_data),
//     });
// }

// void lopgl_load_obj(const lopgl_obj_request_t* request) {
//     lopgl_obj_request_data req_data = {
//         .mesh = 0,
//         .callback = request.callback,
//         .fail_callback = request.fail_callback,
//         .buffer_ptr = request.buffer_ptr,
//         .buffer_size = request.buffer_size,
//         .user_data_ptr = (void*)request.user_data_ptr
//     };
//
//     sfetch_range_t buffer = request.buffer_ptr != NULL ? (sfetch_range_t){request.buffer_ptr, request.buffer_size} : request.buffer;
//     sfetch_send(&(sfetch_request_t){
//         .path = request.path,
//         .callback = obj_fetch_callback,
//         .buffer = buffer,
//         .user_data = SFETCH_RANGE(req_data),
//     });
// }

// /*=== LOAD CUBEMAP IMPLEMENTATION ==================================================*/
//
// typedef struct _cubemap_request_instance_t {
//     int index;
//     _cubemap_request_t* request;
// } _cubemap_request_instance_t;
//
// static bool load_cubemap(_cubemap_request_t* request) {
//     const int desired_channels = 4;
//     int img_widths[6], img_heights[6];
//     stbi_uc* pixels_ptrs[6];
//     sg_image_data img_content;
//
//     for (int i = 0; i < 6; ++i) {
//         int num_channel;
//         pixels_ptrs[i] = stbi_load_from_memory(
//             request.buffer + (i * request.buffer_offset),
//             request.fetched_sizes[i],
//             &img_widths[i], &img_heights[i],
//             &num_channel, desired_channels);
//
//         img_content.subimage[i][0].ptr = pixels_ptrs[i];
//         img_content.subimage[i][0].size = img_widths[i] * img_heights[i] * desired_channels;
//     }
//
//     bool valid = img_widths[0] > 0 && img_heights[0] > 0;
//
//     for (int i = 1; i < 6; ++i) {
//         if (img_widths[i] != img_widths[0] || img_heights[i] != img_heights[0]) {
//             valid = false;
//             break;
//         }
//     }
//
//     if (valid) {
//         /* initialize the sokol-gfx texture */
//         sg_init_image(request.img_id, &(sg_image_desc){
//             .type = SG_IMAGETYPE_CUBE,
//             .width = img_widths[0],
//             .height = img_heights[0],
//             /* set pixel_format to RGBA8 for WebGL */
//             .pixel_format = SG_PIXELFORMAT_RGBA8,
//             .data = img_content
//         });
//     }
//
//     for (int i = 0; i < 6; ++i) {
//         stbi_image_free(pixels_ptrs[i]);
//     }
//
//     return valid;
// }
//
// static void cubemap_fetch_callback(const sfetch_response_t* response) {
//     _cubemap_request_instance_t req_inst = *(_cubemap_request_instance_t*)response.user_data;
//     _cubemap_request_t* request = req_inst.request;
//
//     if (response.fetched) {
//         request.fetched_sizes[req_inst.index] = response.data.size;
//         ++request.finished_requests;
//     }
//     else if (response.failed) {
//         request.failed = true;
//         ++request.finished_requests;
//     }
//
//     if (request.finished_requests == 6) {
//         if (!request.failed) {
//             request.failed = !load_cubemap(request);
//         }
//
//         if (request.failed) {
//             request.fail_callback();
//         }
//     }
// }
//
// void lopgl_load_cubemap(lopgl_cubemap_request_t* request) {
//     // TODO: cleanup and limit cubemap requests
//     state.cubemap_req = (_cubemap_request_t) {
//         .img_id = request.img_id,
//         .buffer = request.buffer_ptr,
//         .buffer_offset = request.buffer_offset,
//         .fail_callback = request.fail_callback
//     };
//
//     const char* cubemap[6] = {
//         request.path_right,
//         request.path_left,
//         request.path_top,
//         request.path_bottom,
//         request.path_front,
//         request.path_back
//     };
//
//     for (int i = 0; i < 6; ++i) {
//         _cubemap_request_instance_t req_instance = {
//             .index = i,
//             .request = &state.cubemap_req
//         };
//         sfetch_send(&(sfetch_request_t){
//             .path = cubemap[i],
//             .callback = cubemap_fetch_callback,
//             .buffer = (sfetch_range_t){request.buffer_ptr + (i * request.buffer_offset), request.buffer_offset},
//             .user_data = SFETCH_RANGE(req_instance),
//         });
//     }
// }
