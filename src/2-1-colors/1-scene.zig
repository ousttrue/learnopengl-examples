//------------------------------------------------------------------------------
//  2-1-1-scene
//------------------------------------------------------------------------------
const sokol = @import("sokol");
const sg = sokol.gfx;
const lopgl = @import("lopgl");
const szmath = @import("szmath");
const Vec3 = szmath.Vec3;
const Mat4 = szmath.Mat4;
const shd = @import("shaders.glsl.zig");

// application state
const state = struct {
    var pip_object = sg.Pipeline{};
    var pip_light = sg.Pipeline{};
    var bind = sg.Bindings{};
    var pass_action = sg.PassAction{};
    var object_color = [3]f32{ 0, 0, 0 };
    var light_color = [3]f32{ 0, 0, 0 };
    var light_pos = Vec3{ .x = 0, .y = 0, .z = 0 };
};

export fn init() void {
    // setup app
    lopgl.setup();

    // set object and light configuration
    state.object_color = .{ 1.0, 0.5, 0.31 };
    state.light_color = .{ 1.0, 1.0, 1.0 };
    state.light_pos = Vec3{ .x = 1.2, .y = 1.0, .z = 2.0 };

    const vertices = [_]f32{
        -0.5, -0.5, -0.5,
        0.5,  -0.5, -0.5,
        0.5,  0.5,  -0.5,
        0.5,  0.5,  -0.5,
        -0.5, 0.5,  -0.5,
        -0.5, -0.5, -0.5,

        -0.5, -0.5, 0.5,
        0.5,  -0.5, 0.5,
        0.5,  0.5,  0.5,
        0.5,  0.5,  0.5,
        -0.5, 0.5,  0.5,
        -0.5, -0.5, 0.5,

        -0.5, 0.5,  0.5,
        -0.5, 0.5,  -0.5,
        -0.5, -0.5, -0.5,
        -0.5, -0.5, -0.5,
        -0.5, -0.5, 0.5,
        -0.5, 0.5,  0.5,

        0.5,  0.5,  0.5,
        0.5,  0.5,  -0.5,
        0.5,  -0.5, -0.5,
        0.5,  -0.5, -0.5,
        0.5,  -0.5, 0.5,
        0.5,  0.5,  0.5,

        -0.5, -0.5, -0.5,
        0.5,  -0.5, -0.5,
        0.5,  -0.5, 0.5,
        0.5,  -0.5, 0.5,
        -0.5, -0.5, 0.5,
        -0.5, -0.5, -0.5,

        -0.5, 0.5,  -0.5,
        0.5,  0.5,  -0.5,
        0.5,  0.5,  0.5,
        0.5,  0.5,  0.5,
        -0.5, 0.5,  0.5,
        -0.5, 0.5,  -0.5,
    };

    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .data = sg.asRange(&vertices),
        .label = "cube-vertices",
    });

    {
        // create shader from code-generated sg_shader_desc
        const simple_shd = sg.makeShader(shd.simpleShaderDesc(sg.queryBackend()));

        // create a pipeline object for object
        var pip_desc = sg.PipelineDesc{
            .shader = simple_shd,
            .depth = .{
                .compare = .LESS_EQUAL,
                .write_enabled = true,
            },
            .label = "object-pipeline",
        };
        // if the vertex layout doesn't have gaps, don't need to provide strides and offsets
        pip_desc.layout.attrs[shd.ATTR_vs_aPos].format = .FLOAT3;
        state.pip_object = sg.makePipeline(pip_desc);
    }

    {
        // create shader from code-generated sg_shader_desc
        const light_cube_shd = sg.makeShader(shd.lightCubeShaderDesc(sg.queryBackend()));

        var pip_desc = sg.PipelineDesc{
            .shader = light_cube_shd,
            .depth = .{
                .compare = .LESS_EQUAL,
                .write_enabled = true,
            },
            .label = "light-cube-pipeline",
        };
        // if the vertex layout doesn't have gaps, don't need to provide strides and offsets
        pip_desc.layout.attrs[shd.ATTR_vs_aPos].format = .FLOAT3;
        // create a pipeline object for light cube
        state.pip_light = sg.makePipeline(pip_desc);
    }

    // a pass action to clear framebuffer
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.1, .g = 0.1, .b = 0.1, .a = 1.0 },
    };
}

export fn frame() void {
    lopgl.update();

    sg.beginPass(.{
        .action = state.pass_action,
        .swapchain = sokol.glue.swapchain(),
    });

    const view = lopgl.viewMatrix();
    const projection = Mat4.persp(
        lopgl.fov(),
        sokol.app.widthf() / sokol.app.heightf(),
        0.1,
        100.0,
    );

    var vs_params = shd.VsParams{
        .view = view.m,
        .projection = projection.m,
        .model = undefined,
    };

    sg.applyPipeline(state.pip_object);
    sg.applyBindings(state.bind);

    vs_params.model = Mat4.identity().m;
    sg.applyUniforms(.VS, shd.SLOT_vs_params, sg.asRange(&vs_params));

    const fs_params = shd.FsParams{
        .objectColor = state.object_color,
        .lightColor = state.light_color,
    };
    sg.applyUniforms(.FS, shd.SLOT_fs_params, sg.asRange(&fs_params));

    sg.draw(0, 36, 1);

    sg.applyPipeline(state.pip_light);
    sg.applyBindings(state.bind);
    var model = Mat4.translate(state.light_pos);
    model = model.mul(Mat4.scale(.{ .x = 0.2, .y = 0.2, .z = 0.2 }));
    vs_params.model = model.m;
    sg.applyUniforms(.VS, shd.SLOT_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 36, 1);

    lopgl.renderHelp();

    sg.endPass();
    sg.commit();
}

export fn event(e: [*c]const sokol.app.Event) void {
    lopgl.handleInput(e);
}

export fn cleanup() void {
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
        .window_title = "Scene - LearnOpenGL",
    });
}
