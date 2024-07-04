//------------------------------------------------------------------------------
//  1-4-1-triangle
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;

// #include "sokol_app.h"
// #include "sokol_gfx.h"
// #include "sokol_glue.h"
// #include "1-triangle.glsl.h"
//
// /* application state */
// static struct {
//     sg_pipeline pip;
//     sg_bindings bind;
//     sg_pass_action pass_action;
// } state;

export fn init() void {
    sg.setup(.{ .environment = sglue.environment() });

    // create shader from code-generated sg_shader_desc
    // const shd = sg.makeShader(shd.Desc(sg.queryBackend));
    // _ = shd;

    //     /* a vertex buffer with 3 vertices */
    //     float vertices[] = {
    //         // positions
    //         -0.5f, -0.5f, 0.0f,     // bottom left
    //         0.5f, -0.5f, 0.0f,      // bottom right
    //         0.0f,  0.5f, 0.0f       // top
    //     };
    //     state.bind.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
    //         .size = sizeof(vertices),
    //         .data = SG_RANGE(vertices),
    //         .label = "triangle-vertices"
    //     });
    //
    //     /* create a pipeline object (default render states are fine for triangle) */
    //     state.pip = sg_make_pipeline(&(sg_pipeline_desc){
    //         .shader = shd,
    //         /* if the vertex layout doesn't have gaps, don't need to provide strides and offsets */
    //         .layout = {
    //             .attrs = {
    //                 [ATTR_vs_position].format = SG_VERTEXFORMAT_FLOAT3
    //             }
    //         },
    //         .label = "triangle-pipeline"
    //     });
    //
    //     /* a pass action to clear framebuffer */
    //     state.pass_action = (sg_pass_action) {
    //         .colors[0] = { .load_action=SG_LOADACTION_CLEAR, .clear_value={0.2f, 0.3f, 0.3f, 1.0f} }
    //     };
}

export fn frame() void {
    //     sg_begin_pass(&(sg_pass){ .action = state.pass_action, .swapchain = sglue_swapchain() });
    //     sg_apply_pipeline(state.pip);
    //     sg_apply_bindings(&state.bind);
    //     sg_draw(0, 3, 1);
    //     sg_end_pass();
    //     sg_commit();
}

export fn cleanup() void {
    //     sg_shutdown();
}

export fn event(_: [*c]const sapp.Event) void {
    //     if (e->type == SAPP_EVENTTYPE_KEY_DOWN) {
    //         if (e->key_code == SAPP_KEYCODE_ESCAPE) {
    //             sapp_request_quit();
    //         }
    //     }
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 800,
        .height = 600,
        .high_dpi = true,
        .window_title = "Triangle - LearnOpenGL",
    });
}
