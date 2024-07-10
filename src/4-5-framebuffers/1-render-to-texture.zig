//------------------------------------------------------------------------------
//  Framebuffers (1)
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const sg = sokol.gfx;
const sokol_helper = @import("sokol_helper");
const shader = @import("1-render-to-texture.glsl.zig");
const lopgl = @import("lopgl");

// application state
const state = struct {
    const offscreen = struct {
        var attachment = sg.Attachments{};
        var attachment_desc = sg.AttachmentsDesc{};
        var pass_action = sg.PassAction{};
        var pip = sg.Pipeline{};
        var bind_cube = sg.Bindings{};
        var bind_plane = sg.Bindings{};
    };
    const display = struct {
        var pass_action = sg.PassAction{};
        var pip = sg.Pipeline{};
        var bind = sg.Bindings{};
    };
    //     uint8_t file_buffer[2 * 1024 * 1024];
};

// static void fail_callback() {
//     state.display.pass_action = (sg_pass_action) {
//         .colors[0] = { .load_action=SG_LOADACTION_CLEAR, .clear_value = { 1.0f, 0.0f, 0.0f, 1.0f } }
//     };
// }

// called initially and when window size changes
fn create_offscreen_pass(width: i32, height: i32) void {
    // destroy previous resource (can be called for invalid id) */
    sg.destroyAttachments(state.offscreen.attachment);
    sg.destroyImage(state.offscreen.attachment_desc.colors[0].image);
    sg.destroyImage(state.offscreen.attachment_desc.depth_stencil.image);

    // create offscreen rendertarget images and pass
    const color_smp_desc = sg.SamplerDesc{
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .compare = .NEVER,
    };
    const color_img_desc = sg.ImageDesc{
        .render_target = true,
        .width = width,
        .height = height,
        .pixel_format = .RGBA8,
        // Webgl 1.0 does not support repeat for textures that are not a power of two in size
        .label = "color-image",
    };
    const color_img = sg.makeImage(color_img_desc);
    const color_smp = sg.makeSampler(color_smp_desc);

    var depth_img_desc = color_img_desc;
    depth_img_desc.pixel_format = .DEPTH;
    depth_img_desc.label = "depth-image";
    const depth_img = sg.makeImage(depth_img_desc);

    state.offscreen.attachment_desc.colors[0].image = color_img;
    state.offscreen.attachment_desc.depth_stencil.image = depth_img;
    state.offscreen.attachment_desc.label = "offscreen-pass";
    state.offscreen.attachment = sg.makeAttachments(state.offscreen.attachment_desc);

    // also need to update the fullscreen-quad texture bindings
    state.display.bind.fs.images[shader.SLOT__diffuse_texture] = color_img;
    state.display.bind.fs.samplers[shader.SLOT_diffuse_texture_smp] = color_smp;
}

export fn init() void {
    lopgl.setup();

    // a render pass with one color- and one depth-attachment image
    create_offscreen_pass(sokol.app.width(), sokol.app.height());

    // a pass action to clear offscreen framebuffer
    state.offscreen.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.1, .g = 0.1, .b = 0.1, .a = 1.0 },
    };

    // a pass action for rendering the fullscreen-quad
    state.display.pass_action.colors[0].load_action = .DONTCARE;
    state.display.pass_action.depth.load_action = .DONTCARE;
    state.display.pass_action.stencil.load_action = .DONTCARE;

    const cube_vertices = [_]f32{
        // positions          // texture Coords
        -0.5, -0.5, -0.5, 0.0, 0.0,
        0.5,  -0.5, -0.5, 1.0, 0.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        -0.5, 0.5,  -0.5, 0.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 0.0,

        -0.5, -0.5, 0.5,  0.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        -0.5, 0.5,  0.5,  0.0, 1.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,

        -0.5, 0.5,  0.5,  1.0, 0.0,
        -0.5, 0.5,  -0.5, 1.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,
        -0.5, 0.5,  0.5,  1.0, 0.0,

        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, 0.5,  0.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,

        -0.5, -0.5, -0.5, 0.0, 1.0,
        0.5,  -0.5, -0.5, 1.0, 1.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0,
        -0.5, -0.5, 0.5,  0.0, 0.0,
        -0.5, -0.5, -0.5, 0.0, 1.0,

        -0.5, 0.5,  -0.5, 0.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5, 0.5,  0.5,  0.0, 0.0,
        -0.5, 0.5,  -0.5, 0.0, 1.0,
    };

    const cube_buffer = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(cube_vertices)),
        .data = sg.asRange(&cube_vertices),
        .label = "cube-vertices",
    });

    const plane_vertices = [_]f32{
        // positions          // texture Coords (note we set these higher than 1 (together with GL_REPEAT as texture wrapping mode). this will cause the floor texture to repeat)
        5.0,  -0.5, 5.0,  2.0, 0.0,
        -5.0, -0.5, 5.0,  0.0, 0.0,
        -5.0, -0.5, -5.0, 0.0, 2.0,

        5.0,  -0.5, 5.0,  2.0, 0.0,
        -5.0, -0.5, -5.0, 0.0, 2.0,
        5.0,  -0.5, -5.0, 2.0, 2.0,
    };

    const plane_buffer = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(plane_vertices)),
        .data = sg.asRange(&plane_vertices),
        .label = "plane-vertices",
    });

    const quad_vertices = [_]f32{ // vertex attributes for a quad that fills the entire screen in Normalized Device Coordinates.
        // positions   // texCoords
        -1.0, 1.0,  0.0, 1.0,
        -1.0, -1.0, 0.0, 0.0,
        1.0,  -1.0, 1.0, 0.0,

        -1.0, 1.0,  0.0, 1.0,
        1.0,  -1.0, 1.0, 0.0,
        1.0,  1.0,  1.0, 1.0,
    };

    const quad_buffer = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(quad_vertices)),
        .data = sg.asRange(&quad_vertices),
        .label = "quad-vertices",
    });

    state.offscreen.bind_cube.vertex_buffers[0] = cube_buffer;
    state.offscreen.bind_plane.vertex_buffers[0] = plane_buffer;

    // resource bindings to render an fullscreen-quad
    state.display.bind.vertex_buffers[0] = quad_buffer;

    {
        // create a pipeline object for offscreen pass
        var pip_desc = sg.PipelineDesc{
            .shader = sg.makeShader(shader.offscreenShaderDesc(sg.queryBackend())),
            .depth = .{
                .compare = .LESS,
                .write_enabled = true,
                .pixel_format = .DEPTH,
            },
            .color_count = 1,
            .label = "offscreen-pipeline",
        };
        pip_desc.layout.attrs[shader.ATTR_vs_offscreen_a_pos].format = .FLOAT3;
        pip_desc.layout.attrs[shader.ATTR_vs_offscreen_a_tex_coords].format = .FLOAT2;
        pip_desc.colors[0] = .{
            .pixel_format = .RGBA8,
        };
        state.offscreen.pip = sg.makePipeline(pip_desc);
    }

    {
        // and another pipeline-state-object for the display pass
        var pip_desc = sg.PipelineDesc{
            .shader = sg.makeShader(shader.displayShaderDesc(sg.queryBackend())),
            .label = "display-pipeline",
        };
        pip_desc.layout.attrs[shader.ATTR_vs_display_a_pos].format = .FLOAT2;
        pip_desc.layout.attrs[shader.ATTR_vs_display_a_tex_coords].format = .FLOAT2;
        state.display.pip = sg.makePipeline(pip_desc);
    }

    sokol_helper.sg_alloc_image_smp(
        &state.offscreen.bind_cube.fs,
        shader.SLOT__diffuse_texture,
        shader.SLOT_diffuse_texture_smp,
    );
    sokol_helper.sg_alloc_image_smp(
        &state.offscreen.bind_plane.fs,
        shader.SLOT__diffuse_texture,
        shader.SLOT_diffuse_texture_smp,
    );
    const container_img_id = state.offscreen.bind_cube.fs.images[shader.SLOT__diffuse_texture];
    _ = container_img_id; // autofix
    const metal_img_id = state.offscreen.bind_plane.fs.images[shader.SLOT__diffuse_texture];
    _ = metal_img_id; // autofix

    //     lopgl_load_image(&(lopgl_image_request_t){
    //             .path = "metal.png",
    //             .img_id = metal_img_id,
    //             .buffer_ptr = state.file_buffer,
    //             .buffer_size = sizeof(state.file_buffer),
    //             .fail_callback = fail_callback
    //     });
    //
    //     lopgl_load_image(&(lopgl_image_request_t){
    //             .path = "container.jpg",
    //             .img_id = container_img_id,
    //             .buffer_ptr = state.file_buffer,
    //             .buffer_size = sizeof(state.file_buffer),
    //             .fail_callback = fail_callback
    //     });
}

export fn frame() void {
    //     lopgl_update();

    //     HMM_Mat4 view = lopgl_view_matrix();
    //     HMM_Mat4 projection = HMM_Perspective_RH_NO(lopgl_fov(), (float)sapp_width() / (float)sapp_height(), 0.1f, 100.0f);

    //     vs_params_t vs_params = {
    //         .view = view,
    //         .projection = projection
    //     };

    // the offscreen pass, rendering an rotating, untextured cube into a render target image
    sg.beginPass(.{
        .action = state.offscreen.pass_action,
        .attachments = state.offscreen.attachment,
    });
    sg.applyPipeline(state.offscreen.pip);
    sg.applyBindings(state.offscreen.bind_cube);

    // vs_params.model = HMM_Translate(HMM_V3(-1.0f, 0.0f, -1.0f));
    // sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 36, 1);

    // vs_params.model = HMM_Translate(HMM_V3(2.0f, 0.0f, 0.0f));
    // sg.applyUniforms(.VS, shader.SLOT_vs_params, &SG_RANGE(vs_params));
    sg.draw(0, 36, 1);

    sg.applyBindings(state.offscreen.bind_plane);

    // vs_params.model = HMM_M4D(1.0f);
    // sg.applyUniforms(.VS, shader.SLOT_vs_params, &SG_RANGE(vs_params));
    sg.draw(0, 6, 1);

    sg.endPass();

    // and the display-pass, rendering a quad, using the previously rendered
    // offscreen render-target as texture
    sg.beginPass(.{
        .action = state.display.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sg.applyPipeline(state.display.pip);
    sg.applyBindings(state.display.bind);
    sg.draw(0, 6, 1);

    //     lopgl_render_help();

    sg.endPass();
    sg.commit();
}

export fn event(e: [*c]const sokol.app.Event) void {
    if (e.*.type == .RESIZED) {
        create_offscreen_pass(e.*.framebuffer_width, e.*.framebuffer_height);
    }

    //     lopgl_handle_input(e);
}

export fn cleanup() void {
    // lopgl_shutdown();
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
        .window_title = "Render To Texture (LearnOpenGL)",
    });
}
