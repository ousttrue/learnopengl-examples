//------------------------------------------------------------------------------
//  Basic Lighting (1)
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const sg = sokol.gfx;
const rowmath = @import("rowmath");
const Vec3 = rowmath.Vec3;
const shader = @import("1-ambient.glsl.zig");
const lopgl = @import("lopgl");

// application state
const state = struct {
    var pip_object = sg.Pipeline{};
    var pip_light = sg.Pipeline{};
    var bind = sg.Bindings{};
    var pass_action = sg.PassAction{};
    var object_color = Vec3.zero;
    var light_color = Vec3.zero;
    var light_pos = Vec3.zero;
};

export fn init()void {
//     lopgl_setup();
//
//     // set object and light configuration
//     state.object_color = HMM_V3(1.0f, 0.5f, 0.31f);
//     state.light_color = HMM_V3(1.0f, 1.0f, 1.0f);
//     state.light_pos = HMM_V3(1.2f, 1.0f, 2.0f);
//
//     float vertices[] = {
//         -0.5f, -0.5f, -0.5f,
//         0.5f, -0.5f, -0.5f,
//         0.5f,  0.5f, -0.5f,
//         0.5f,  0.5f, -0.5f,
//         -0.5f,  0.5f, -0.5f,
//         -0.5f, -0.5f, -0.5f,
//
//         -0.5f, -0.5f,  0.5f,
//         0.5f, -0.5f,  0.5f,
//         0.5f,  0.5f,  0.5f,
//         0.5f,  0.5f,  0.5f,
//         -0.5f,  0.5f,  0.5f,
//         -0.5f, -0.5f,  0.5f,
//
//         -0.5f,  0.5f,  0.5f,
//         -0.5f,  0.5f, -0.5f,
//         -0.5f, -0.5f, -0.5f,
//         -0.5f, -0.5f, -0.5f,
//         -0.5f, -0.5f,  0.5f,
//         -0.5f,  0.5f,  0.5f,
//
//         0.5f,  0.5f,  0.5f,
//         0.5f,  0.5f, -0.5f,
//         0.5f, -0.5f, -0.5f,
//         0.5f, -0.5f, -0.5f,
//         0.5f, -0.5f,  0.5f,
//         0.5f,  0.5f,  0.5f,
//
//         -0.5f, -0.5f, -0.5f,
//         0.5f, -0.5f, -0.5f,
//         0.5f, -0.5f,  0.5f,
//         0.5f, -0.5f,  0.5f,
//         -0.5f, -0.5f,  0.5f,
//         -0.5f, -0.5f, -0.5f,
//
//         -0.5f,  0.5f, -0.5f,
//         0.5f,  0.5f, -0.5f,
//         0.5f,  0.5f,  0.5f,
//         0.5f,  0.5f,  0.5f,
//         -0.5f,  0.5f,  0.5f,
//         -0.5f,  0.5f, -0.5f,
//     };
//
//     state.bind.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
//         .size = sizeof(vertices),
//         .data = SG_RANGE(vertices),
//         .label = "cube-vertices"
//     });
//
//     /* create shader from code-generated sg_shader_desc */
//     sg_shader ambient_shd = sg_make_shader(ambient_shader_desc(sg_query_backend()));
//
//     /* create a pipeline object for object */
//     state.pip_object = sg_make_pipeline(&(sg_pipeline_desc){
//         .shader = ambient_shd,
//         /* if the vertex layout doesn't have gaps, don't need to provide strides and offsets */
//         .layout = {
//             .attrs = {
//                 [ATTR_vs_aPos].format = SG_VERTEXFORMAT_FLOAT3
//             }
//         },
//         .depth = {
//             .compare =SG_COMPAREFUNC_LESS_EQUAL,
//             .write_enabled =true,
//         },
//         .label = "object-pipeline"
//     });
//
//     /* create shader from code-generated sg_shader_desc */
//     sg_shader light_cube_shd = sg_make_shader(light_cube_shader_desc(sg_query_backend()));
//
//     /* create a pipeline object for light cube */
//     state.pip_light = sg_make_pipeline(&(sg_pipeline_desc){
//         .shader = light_cube_shd,
//         /* if the vertex layout doesn't have gaps, don't need to provide strides and offsets */
//         .layout = {
//             .attrs = {
//                 [ATTR_vs_aPos].format = SG_VERTEXFORMAT_FLOAT3
//             }
//         },
//         .depth = {
//             .compare = SG_COMPAREFUNC_LESS_EQUAL,
//             .write_enabled = true,
//         },
//         .label = "light-cube-pipeline"
//     });
//
//     /* a pass action to clear framebuffer */
//     state.pass_action = (sg_pass_action) {
//         .colors[0] = { .load_action=SG_LOADACTION_CLEAR, .clear_value={0.1f, 0.1f, 0.1f, 1.0f} }
//     };
}

export fn frame()void {
//     lopgl_update();
//
//     sg_begin_pass(&(sg_pass){ .action = state.pass_action, .swapchain = sglue_swapchain() });
//
//     HMM_Mat4 view = lopgl_view_matrix();
//     HMM_Mat4 projection = HMM_Perspective_RH_NO(lopgl_fov(), (float)sapp_width() / (float)sapp_height(), 0.1f, 100.0f);
//
//     vs_params_t vs_params = {
//         .view = view,
//         .projection = projection
//     };
//
//     sg_apply_pipeline(state.pip_object);
//     sg_apply_bindings(&state.bind);
//
//     vs_params.model = HMM_M4D(1.f);;
//     sg_apply_uniforms(SG_SHADERSTAGE_VS, SLOT_vs_params, &SG_RANGE(vs_params));
//
//     fs_params_t fs_params = {
//         .objectColor = state.object_color,
//         .lightColor = state.light_color,
//     };
//     sg_apply_uniforms(SG_SHADERSTAGE_FS, SLOT_fs_params, &SG_RANGE(fs_params));
//
//     sg_draw(0, 36, 1);
//
//     sg_apply_pipeline(state.pip_light);
//     sg_apply_bindings(&state.bind);
//     vs_params.model = HMM_Translate(state.light_pos);
//     vs_params.model = HMM_MulM4(vs_params.model, HMM_Scale(HMM_V3(0.2f, 0.2f, 0.2f)));
//     sg_apply_uniforms(SG_SHADERSTAGE_VS, SLOT_vs_params, &SG_RANGE(vs_params));
//     sg_draw(0, 36, 1);
//
//     lopgl_render_help();
//
//     sg_end_pass();
//     sg_commit();
}

export fn event(e:[*c]const sokol.app.Event)void {
    lopgl.handleInput(e);
}


export fn cleanup()void {
    lopgl.shutdown();
}

pub fn main() void {
    return sokol.app.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 800,
        .height = 600,
        .high_dpi = true,
        .window_title = "Ambient (LearnOpenGL)",
    });
}
