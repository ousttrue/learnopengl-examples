//------------------------------------------------------------------------------
//  1-6-1-texture
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const sg = sokol.gfx;
// #include "sokol_app.h"
// #include "sokol_gfx.h"
// #include "sokol_glue.h"
// #include "sokol_fetch.h"
// #include "sokol_helper.h"
const shader = @import("1-texture.glsl.zig");

// Mipmaps are left out of this example because currently Sokol does not provide
// a generic way to generate them.

// application state
const state = struct {
    var pip = sg.Pipeline{};
    var bind = sg.Bindings{};
    var pass_action = sg.PassAction{};
    var file_buffer = [1]u8{0} ** (512 * 1024);
};

export fn init() void {
    sg.setup(.{ .environment = sokol.glue.environment() });

    // setup sokol-fetch
    sokol.fetch.setup(.{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
    });

    // Allocate an image handle, but don't actually initialize the image yet,
    // this happens later when the asynchronous file load has finished.
    // Any draw calls containing such an "incomplete" image handle
    // will be silently dropped.
    // sg.allocImageSmp(state.bind.fs, shader.SLOT__ourTexture, SLOT_ourTexture_smp);

    const vertices = [_]f32{
        // positions         // colors           // texture coords
        0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top right
        0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom right
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom let
        -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, // top let
    };
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .data = sg.asRange(&vertices),
        .label = "quad-vertices",
    });

    // an index buffer with 2 triangles
    const indices = [_]u16{
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };
    state.bind.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .size = @sizeOf(@TypeOf(indices)),
        .data = sg.asRange(&indices),
        .label = "quad-indices",
    });

    // create shader from code-generated sg_shader_desc
    const shd = sg.makeShader(shader.simpleShaderDesc(sg.queryBackend()));

    // create a pipeline object (default render states are fine for triangle)
    var pip_desc = sg.PipelineDesc{
        .shader = shd,
        .index_type = .UINT16,
        .label = "triangle-pipeline",
    };
    // if the vertex layout doesn't have gaps, don't need to provide strides and offsets
    pip_desc.layout.attrs[shader.ATTR_vs_position].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_aColor].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_aTexCoord].format = .FLOAT2;
    state.pip = sg.makePipeline(pip_desc);

    // a pass action to clear framebuffer
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.2, .g = 0.3, .b = 0.3, .a = 1.0 },
    };

    // start loading the PNG file
    _ = sokol.fetch.send(.{
        .path = "container.jpg",
        .callback = fetch_callback,
        .buffer = sokol.fetch.asRange(&state.file_buffer),
    });
}

// The fetch-callback is called by sokol_fetch.h when the data is loaded, or when an error has occurred.

export fn fetch_callback(_: [*c]const sokol.fetch.Response) void {
    //     if (response->fetched) {
    //         /* the file data has been fetched, since we provided a big-enough
    //            buffer we can be sure that all data has been loaded here
    //         */
    //         int img_width, img_height, num_channels;
    //         const int desired_channels = 4;
    //         stbi_uc* pixels = stbi_load_from_memory(
    //             response->data.ptr,
    //             (int)response->data.size,
    //             &img_width, &img_height,
    //             &num_channels, desired_channels);
    //         if (pixels) {
    //             /* initialize the sokol-gfx texture */
    //             sg_init_image(state.bind.fs.images[SLOT__ourTexture], &(sg_image_desc){
    //                 .width = img_width,
    //                 .height = img_height,
    //                 /* set pixel_format to RGBA8 for WebGL */
    //                 .pixel_format = SG_PIXELFORMAT_RGBA8,
    //                 .data.subimage[0][0] = {
    //                     .ptr = pixels,
    //                     .size = img_width * img_height * 4,
    //                 }
    //             });
    //             stbi_image_free(pixels);
    //         }
    //     }
    //     else if (response->failed) {
    //         // if loading the file failed, set clear color to red
    //         state.pass_action = (sg_pass_action) {
    //             .colors[0] = { .load_action = SG_LOADACTION_CLEAR, .clear_value = { 1.0f, 0.0f, 0.0f, 1.0f } }
    //         };
    //     }
}

export fn frame() void {
    //     sfetch_dowork();
    //     sg_begin_pass(&(sg_pass){ .action = state.pass_action, .swapchain = sglue_swapchain() });
    //     sg_apply_pipeline(state.pip);
    //     sg_apply_bindings(&state.bind);
    //     sg_draw(0, 6, 1);
    //     sg_end_pass();
    //     sg_commit();
}

export fn cleanup() void {
    sg.shutdown();
    sokol.fetch.shutdown();
}

export fn event(e: [*c]const sokol.app.Event) void {
    if (e.*.type == .KEY_DOWN) {
        if (e.*.key_code == .ESCAPE) {
            sokol.app.requestQuit();
        }
    }
}

pub fn main() void {
    sokol.app.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 800,
        .height = 600,
        .high_dpi = true,
        .window_title = "Texture - LearnOpenGL",
    });
}
