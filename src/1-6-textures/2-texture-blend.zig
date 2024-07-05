//------------------------------------------------------------------------------
//  1-6-2-texture-blend
//------------------------------------------------------------------------------
const c = @cImport({
    @cInclude("stb_image.h");
});
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("2-texture-blend.glsl.zig");
const sokol_helper = @import("sokol_helper");

//  Mipmaps are left out of this example because currently Sokol does not provide a generic way to generate them.

// application state
const state = struct {
    var pip = sg.Pipeline{};
    var bind = sg.Bindings{};
    var pass_action = sg.PassAction{};
    var file_buffer = [1]u8{0} ** (256 * 1024);
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
    sokol_helper.sg_alloc_image_smp(
        &state.bind.fs,
        shader.SLOT__ourTexture,
        shader.SLOT_ourTexture_smp,
    );

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
export fn fetch_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        // the file data has been fetched, since we provided a big-enough buffer we can be sure that all data has been loaded here

        var img_width: c_int = undefined;
        var img_height: c_int = undefined;
        var num_channels: c_int = undefined;
        const desired_channels = 4;
        const pixels = c.stbi_load_from_memory(
            @ptrCast(response.*.data.ptr),
            @intCast(response.*.data.size),
            &img_width,
            &img_height,
            &num_channels,
            desired_channels,
        );
        if (pixels != null) {
            // initialize the sokol-gfx texture
            var img_desc = sg.ImageDesc{
                .width = img_width,
                .height = img_height,
                // set pixel_format to RGBA8 for WebGL
                .pixel_format = .RGBA8,
            };
            img_desc.data.subimage[0][0] = .{
                .ptr = pixels,
                .size = @intCast(img_width * img_height * 4),
            };
            sg.initImage(state.bind.fs.images[shader.SLOT__ourTexture], img_desc);
            c.stbi_image_free(pixels);
        }
    } else if (response.*.failed) {
        // if loading the file failed, set clear color to red
        state.pass_action.colors[0] = .{
            .load_action = .CLEAR,
            .clear_value = .{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 1.0 },
        };
    }
}

export fn frame() void {
    sokol.fetch.dowork();
    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.draw(0, 6, 1);
    sg.endPass();
    sg.commit();
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
        .window_title = "Texture Blend - LearnOpenGL",
    });
}
