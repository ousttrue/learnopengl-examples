//------------------------------------------------------------------------------
//  1-9-2-walk
//------------------------------------------------------------------------------
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"
#include "sokol_fetch.h"
#include "sokol_time.h"
#include "hmm/HandmadeMath.h"
#define LOPGL_APP_IMPL
#include "../lopgl_app.h"
#include "shaders.glsl.h"

/* application state */
static struct {
    sg_pipeline pip;
    sg_bindings bind;
    sg_pass_action pass_action;
    uint8_t file_buffer[256 * 1024];
    hmm_vec3 cube_positions[10];
    hmm_vec3 camera_pos;
    hmm_vec3 camera_front;
    hmm_vec3 camera_up;
    uint64_t last_time;
    uint64_t delta_time;
} state;

static void fetch_callback(const sfetch_response_t*);

static void init(void) {
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });

     /* setup sokol-fetch
        The 1 channel and 1 lane configuration essentially serializes
        IO requests. Which is just fine for this example. */
    sfetch_setup(&(sfetch_desc_t){
        .max_requests = 2,
        .num_channels = 1,
        .num_lanes = 1
    });

    /* initialize sokol_time */
    stm_setup();

    /* Allocate an image handle, but don't actually initialize the image yet,
       this happens later when the asynchronous file load has finished.
       Any draw calls containing such an "incomplete" image handle
       will be silently dropped.
    */
    state.bind.fs_images[SLOT_texture1] = sg_alloc_image();
    state.bind.fs_images[SLOT_texture2] = sg_alloc_image();

    /* flip images vertically after loading */
    stbi_set_flip_vertically_on_load(true);

    // set default camera configuration
    state.camera_pos = HMM_Vec3(0.0f, 0.0f,  3.0f);
    state.camera_front = HMM_Vec3(0.0f, 0.0f, -1.0f);
    state.camera_up = HMM_Vec3(0.0f, 1.0f,  0.0f);

    state.cube_positions[0] = HMM_Vec3( 0.0f,  0.0f,  0.0f);
    state.cube_positions[1] = HMM_Vec3( 2.0f,  5.0f, -15.0f);
    state.cube_positions[2] = HMM_Vec3(-1.5f, -2.2f, -2.5f);
    state.cube_positions[3] = HMM_Vec3(-3.8f, -2.0f, -12.3f);
    state.cube_positions[4] = HMM_Vec3( 2.4f, -0.4f, -3.5f);
    state.cube_positions[5] = HMM_Vec3(-1.7f,  3.0f, -7.5f);
    state.cube_positions[6] = HMM_Vec3( 1.3f, -2.0f, -2.5f);
    state.cube_positions[7] = HMM_Vec3( 1.5f,  2.0f, -2.5f);
    state.cube_positions[8] = HMM_Vec3( 1.5f,  0.2f, -1.5f);
    state.cube_positions[9] = HMM_Vec3(-1.3f,  1.0f, -1.5f);

    float vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    
    state.bind.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
        .size = sizeof(vertices),
        .data = SG_RANGE(vertices),
        .label = "cube-vertices"
    });

    /* create shader from code-generated sg_shader_desc */
    sg_shader shd = sg_make_shader(simple_shader_desc(sg_query_backend()));

    /* create a pipeline object (default render states are fine for triangle) */
    state.pip = sg_make_pipeline(&(sg_pipeline_desc){
        .shader = shd,
        /* if the vertex layout doesn't have gaps, don't need to provide strides and offsets */
        .layout = {
            .attrs = {
                [ATTR_vs_aPos].format = SG_VERTEXFORMAT_FLOAT3,
                [ATTR_vs_aTexCoord].format = SG_VERTEXFORMAT_FLOAT2
            }
        },
        .depth_stencil = {
            .depth_compare_func = SG_COMPAREFUNC_LESS_EQUAL,
            .depth_write_enabled = true,
        },
        .label = "triangle-pipeline"
    });
    
    /* a pass action to clear framebuffer */
    state.pass_action = (sg_pass_action) {
        .colors[0] = { .load_action=SG_LOADACTION_CLEAR, .clear_value={0.2f, 0.3f, 0.3f, 1.0f} }
    };

    sg_image image1 = state.bind.fs_images[SLOT_texture1];
    sg_image image2 = state.bind.fs_images[SLOT_texture2];

    /* start loading the JPG file */
    sfetch_send(&(sfetch_request_t){
        .path = "container.jpg",
        .callback = fetch_callback,
        .buffer_ptr = state.file_buffer,
        .buffer_size = sizeof(state.file_buffer),
        .user_data_ptr = &image1,
        .user_data_size = sizeof(image1)
    });

    /* start loading the PNG file
       we can use the same buffer because we are serializing the request (see sfetch_setup) */
    sfetch_send(&(sfetch_request_t){
        .path = "awesomeface.png",
        .callback = fetch_callback,
        .buffer_ptr = state.file_buffer,
        .buffer_size = sizeof(state.file_buffer),
        .user_data_ptr = &image2,
        .user_data_size = sizeof(image2)
    });
}

/* The fetch-callback is called by sokol_fetch.h when the data is loaded,
   or when an error has occurred.
*/
static void fetch_callback(const sfetch_response_t* response) {
    if (response->fetched) {
        /* the file data has been fetched, since we provided a big-enough
           buffer we can be sure that all data has been loaded here
        */
        int img_width, img_height, num_channels;
        const int desired_channels = 4;
        stbi_uc* pixels = stbi_load_from_memory(
            response->buffer_ptr,
            (int)response->fetched_size,
            &img_width, &img_height,
            &num_channels, desired_channels);
        if (pixels) {
            sg_image image = *(sg_image*)response->user_data;
            sg_init_image(image, &(sg_image_desc) {
                .width = img_width,
                .height = img_height,
                /* set pixel_format to RGBA8 for WebGL */
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .wrap_u = SG_WRAP_REPEAT,
                .wrap_v = SG_WRAP_REPEAT,
                .min_filter = SG_FILTER_LINEAR,
                .mag_filter = SG_FILTER_LINEAR,
                .content.subimage[0][0] = {
                    .ptr = pixels,
                    .size = img_width * img_height * 4,
                }
            });
            stbi_image_free(pixels);
        }
    }
    else if (response->failed) {
        // if loading the file failed, set clear color to red
        state.pass_action = (sg_pass_action) {
            .colors[0] = { .action = SG_ACTION_CLEAR, .val = { 1.0f, 0.0f, 0.0f, 1.0f } }
        };
    }
}

void frame(void) {
    state.delta_time = stm_laptime(&state.last_time);
    sfetch_dowork();

    hmm_mat4 view = HMM_LookAt(state.camera_pos, HMM_AddVec3(state.camera_pos, state.camera_front), state.camera_up);
    hmm_mat4 projection = HMM_Perspective(45.0f, (float)sapp_width() / (float)sapp_height(), 0.1f, 100.0f);

    sg_begin_default_pass(&state.pass_action, sapp_width(), sapp_height());
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);

    vs_params_t vs_params = {
        .view = view,
        .projection = projection
    };

    for(size_t i = 0; i < 10; i++) {
        hmm_mat4 model = HMM_Translate(state.cube_positions[i]);
        float angle = 20.0f * i; 
        model = HMM_MultiplyMat4(model, HMM_Rotate(angle, HMM_Vec3(1.0f, 0.3f, 0.5f)));
        vs_params.model = model;
        sg_apply_uniforms(SG_SHADERSTAGE_VS, SLOT_vs_params, &SG_RANGE(vs_params));

        sg_draw(0, 36, 1);
    }

    sg_end_pass();
    sg_commit();
}

void event(const sapp_event* e) {
    if (e->type == SAPP_EVENTTYPE_KEY_DOWN) {
        if (e->key_code == SAPP_KEYCODE_ESCAPE) {
            sapp_request_quit();
        }

        float camera_speed = 5.f * (float) stm_sec(state.delta_time);

        if (e->key_code == SAPP_KEYCODE_W) {
            hmm_vec3 offset = HMM_MultiplyVec3f(state.camera_front, camera_speed);
            state.camera_pos = HMM_AddVec3(state.camera_pos, offset);
        }
        if (e->key_code == SAPP_KEYCODE_S) {
            hmm_vec3 offset = HMM_MultiplyVec3f(state.camera_front, camera_speed);
            state.camera_pos = HMM_SubtractVec3(state.camera_pos, offset);
        }
        if (e->key_code == SAPP_KEYCODE_A) {
            hmm_vec3 offset = HMM_MultiplyVec3f(HMM_NormalizeVec3(HMM_Cross(state.camera_front, state.camera_up)), camera_speed);
            state.camera_pos = HMM_SubtractVec3(state.camera_pos, offset);
        }
        if (e->key_code == SAPP_KEYCODE_D) {
            hmm_vec3 offset = HMM_MultiplyVec3f(HMM_NormalizeVec3(HMM_Cross(state.camera_front, state.camera_up)), camera_speed);
            state.camera_pos = HMM_AddVec3(state.camera_pos, offset);
        }
    }
}


void cleanup(void) {
    sg_shutdown();
    sfetch_shutdown();
}

sapp_desc sokol_main(int argc, char* argv[]) {
    return (sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 800,
        .height = 600,
        .high_dpi = true,
        .window_title = "Walk - LearnOpenGL",
    };
}
