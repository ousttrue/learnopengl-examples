//------------------------------------------------------------------------------
//  1-8-3-more-cubes
//------------------------------------------------------------------------------
const c = @cImport({
    @cInclude("stb_image.h");
});
const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("shaders.glsl.zig");
const math = @import("szmath");
const sokol_helper = @import("sokol_helper");

// application state
const state = struct {
    var pip = sg.Pipeline{};
    var bind = sg.Bindings{};
    var pass_action = sg.PassAction{};
    var file_buffer = [1]u8{0} ** (256 * 1024);
    var cube_positions = [1]math.Vec3{.{ .x = 0, .y = 0, .z = 0 }} ** 10;
};

export fn init() void {
    sg.setup(.{ .environment = sokol.glue.environment() });

    // setup sokol-fetch
    // The 1 channel and 1 lane configuration essentially serializes
    // IO requests. Which is just fine for this example.
    sokol.fetch.setup(.{
        .max_requests = 2,
        .num_channels = 1,
        .num_lanes = 1,
    });

    // Allocate an image handle, but don't actually initialize the image yet,
    // this happens later when the asynchronous file load has finished.
    // Any draw calls containing such an "incomplete" image handle
    // will be silently dropped.
    sokol_helper.sg_alloc_image_smp(
        &state.bind.fs,
        shader.SLOT__texture1,
        shader.SLOT_texture1_smp,
    );
    sokol_helper.sg_alloc_image_smp(
        &state.bind.fs,
        shader.SLOT__texture2,
        shader.SLOT_texture2_smp,
    );

    // flip images vertically after loading
    c.stbi_set_flip_vertically_on_load(1);

    state.cube_positions[0] = .{ .x = 0.0, .y = 0.0, .z = 0.0 };
    state.cube_positions[1] = .{ .x = 2.0, .y = 5.0, .z = -15.0 };
    state.cube_positions[2] = .{ .x = -1.5, .y = -2.2, .z = -2.5 };
    state.cube_positions[3] = .{ .x = -3.8, .y = -2.0, .z = -12.3 };
    state.cube_positions[4] = .{ .x = 2.4, .y = -0.4, .z = -3.5 };
    state.cube_positions[5] = .{ .x = -1.7, .y = 3.0, .z = -7.5 };
    state.cube_positions[6] = .{ .x = 1.3, .y = -2.0, .z = -2.5 };
    state.cube_positions[7] = .{ .x = 1.5, .y = 2.0, .z = -2.5 };
    state.cube_positions[8] = .{ .x = 1.5, .y = 0.2, .z = -1.5 };
    state.cube_positions[9] = .{ .x = -1.3, .y = 1.0, .z = -1.5 };

    const vertices = [_]f32{
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

    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .data = sg.asRange(&vertices),
        .label = "cube-vertices",
    });

    // create shader from code-generated sg_shader_desc
    const shd = sg.makeShader(shader.simpleShaderDesc(sg.queryBackend()));

    // create a pipeline object (default render states are fine for triangle)
    var pip_desc = sg.PipelineDesc{
        .shader = shd,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .label = "triangle-pipeline",
    };
    // if the vertex layout doesn't have gaps, don't need to provide strides and offsets
    pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_aTexCoord].format = .FLOAT2;
    state.pip = sg.makePipeline(pip_desc);

    // a pass action to clear framebuffer
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.2, .g = 0.3, .b = 0.3, .a = 1.0 },
    };

    const image1 = state.bind.fs.images[shader.SLOT__texture1];
    const image2 = state.bind.fs.images[shader.SLOT__texture2];

    // start loading the JPG file
    _ = sokol.fetch.send(.{
        .path = "container.jpg",
        .callback = fetch_callback,
        .buffer = sokol.fetch.asRange(&state.file_buffer),
        .user_data = sokol.fetch.asRange(&image1),
    });

    // start loading the PNG file
    // we can use the same buffer because we are serializing the request (see sfetch_setup)
    _ = sokol.fetch.send(.{
        .path = "awesomeface.png",
        .callback = fetch_callback,
        .buffer = sokol.fetch.asRange(&state.file_buffer),
        .user_data = sokol.fetch.asRange(&image2),
    });
}

// The fetch-callback is called by sokol_fetch.h when the data is loaded,
// or when an error has occurred.
export fn fetch_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        // the file data has been fetched, since we provided a big-enough
        // buffer we can be sure that all data has been loaded here
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
            const image: *sg.Image = @ptrCast(@alignCast(response.*.user_data));
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
            sg.initImage(image.*, img_desc);
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

    // note that we're translating the scene in the reverse direction of where we want to move
    const view = math.Mat4.translate(.{ .x = 0.0, .y = 0.0, .z = -3.0 });

    const projection = math.Mat4.persp(
        45.0,
        @as(f32, @floatFromInt(sokol.app.width())) / @as(f32, @floatFromInt(sokol.app.height())),
        0.1,
        100.0,
    );

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);

    var vs_params = shader.VsParams{
        .view = view.m,
        .projection = projection.m,
        .model = undefined,
    };

    for (0..10) |i| {
        var model = math.Mat4.translate(state.cube_positions[i]);
        const angle = 20.0 * @as(f32, @floatFromInt(i));
        model = model.mul(math.Mat4.rotate(
            std.math.degreesToRadians(angle),
            .{ .x = 1.0, .y = 0.3, .z = 0.5 },
        ));
        vs_params.model = model.m;
        sg.applyUniforms(.VS, shader.SLOT_vs_params, sg.asRange(&vs_params));

        sg.draw(0, 36, 1);
    }

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
        .window_title = "More Cubes - LearnOpenGL",
    });
}
