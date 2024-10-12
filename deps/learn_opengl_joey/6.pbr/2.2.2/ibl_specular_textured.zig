// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/6.pbr/2.2.2.ibl_specular_textured/ibl_specular_textured.cpp
const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const pbr_shader = @import("pbr.glsl.zig");
const background_shader = @import("background.glsl.zig");
const rowmath = @import("rowmath");
const stb_image = @import("stb_image");
const InputState = rowmath.InputState;
const OrbitCamera = rowmath.OrbitCamera;
const Vec3 = rowmath.Vec3;
const Vec2 = rowmath.Vec2;
const Mat4 = rowmath.Mat4;
const Sphere = @import("Sphere.zig");
const Texture = @import("Texture.zig");
const FloatTexture = @import("FloatTexture.zig");
const PbrMaterial = @import("PbrMaterial.zig");
const EnvCubemap = @import("EnvCubemap.zig");
const IrradianceMap = @import("IrradianceMap.zig");
const PrefilterMap = @import("PrefilterMap.zig");
const BrdfLut = @import("BrdfLut.zig");

// settings
const SCR_WIDTH = 1280;
const SCR_HEIGHT = 720;
const TITLE = "6.2.2.2 ibl_specular_textured";
var fetch_buffer: [1024 * 1024 * 10]u8 = undefined;

const state = struct {
    var pbr_pip = sg.Pipeline{};
    var background_pip = sg.Pipeline{};
    var sphere: Sphere = undefined;

    var iron: ?PbrMaterial = null;
    var gold: ?PbrMaterial = null;
    var grass: ?PbrMaterial = null;
    var plastic: ?PbrMaterial = null;
    var wall: ?PbrMaterial = null;

    var input = InputState{};
    var orbit = OrbitCamera{};

    var lightPositions = [_][4]f32{
        .{ -10.0, 10.0, 10.0, 0 },
        .{ 10.0, 10.0, 10.0, 0 },
        .{ -10.0, -10.0, 10.0, 0 },
        .{ 10.0, -10.0, 10.0, 0 },
    };
    var lightColors = [_][4]f32{
        .{ 300.0, 300.0, 300.0, 0 },
        .{ 300.0, 300.0, 300.0, 0 },
        .{ 300.0, 300.0, 300.0, 0 },
        .{ 300.0, 300.0, 300.0, 0 },
    };

    var env_cubemap: ?EnvCubemap = null;
    var irradiance_map: ?IrradianceMap = null;
    var prefilter_map: ?PrefilterMap = null;
    var brdf_lut: ?BrdfLut = null;
};

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });
    sokol.time.setup();

    {
        var pip_desc = sg.PipelineDesc{
            .label = "pbr",
            .shader = sg.makeShader(pbr_shader.pbrShaderDesc(
                sg.queryBackend(),
            )),
            .depth = .{
                .write_enabled = true,
                .compare = .LESS_EQUAL,
            },
            .index_type = .UINT16,
        };
        pip_desc.layout.attrs[pbr_shader.ATTR_vs_aPos].format = .FLOAT3;
        pip_desc.layout.attrs[pbr_shader.ATTR_vs_aNormal].format = .FLOAT3;
        pip_desc.layout.attrs[pbr_shader.ATTR_vs_aTexCoords].format = .FLOAT2;
        state.pbr_pip = sg.makePipeline(pip_desc);
    }
    {
        var pip_desc = sg.PipelineDesc{
            .label = "background",
            .shader = sg.makeShader(background_shader.backgroundShaderDesc(
                sg.queryBackend(),
            )),
            .depth = .{
                .write_enabled = true,
                .compare = .LESS_EQUAL,
            },
        };
        pip_desc.layout.attrs[pbr_shader.ATTR_vs_aPos].format = .FLOAT3;
        pip_desc.layout.buffers[0].stride = 4 * 8;
        state.background_pip = sg.makePipeline(pip_desc);
    }

    state.sphere = Sphere.init(std.heap.c_allocator) catch @panic("Sphere.init");

    sokol.fetch.setup(.{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
    });
    _ = sokol.fetch.send(.{
        .path = "resources/textures/hdr/newport_loft.hdr",
        .callback = hdr_texture_callback,
        .buffer = sokol.fetch.asRange(&fetch_buffer),
    });

    std.debug.print("\n\n", .{});
}

export fn hdr_texture_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        const texture = FloatTexture.load(
            response.*.data.ptr,
            response.*.data.size,
        ) catch @panic("FloatTexture.load");

        const env_cubemap = EnvCubemap.init();
        env_cubemap.render(texture);

        const irradiance_map = IrradianceMap.init();
        irradiance_map.render(env_cubemap);

        const prefilter_map = PrefilterMap.init();
        prefilter_map.render(env_cubemap);

        const brdf_lut = BrdfLut.init();
        brdf_lut.render();

        state.env_cubemap = env_cubemap;
        state.irradiance_map = irradiance_map;
        state.prefilter_map = prefilter_map;
        state.brdf_lut = brdf_lut;
    } else if (response.*.failed) {
        std.debug.print("[hdr_texture_callback] failed\n", .{});
    }
}

export fn frame() void {
    defer sg.commit();
    sokol.fetch.dowork();

    state.input.screen_width = sokol.app.widthf();
    state.input.screen_height = sokol.app.heightf();
    state.orbit.frame(state.input);
    state.input.mouse_wheel = 0;
    const view = state.orbit.viewMatrix();
    const projection = state.orbit.projectionMatrix();

    {
        const pass_action = sg.PassAction{
            .colors = .{
                .{
                    .load_action = .CLEAR,
                    .clear_value = .{ .r = 0.2, .g = 0.3, .b = 0.3, .a = 1.0 },
                },
                .{},
                .{},
                .{},
            },
        };
        sg.beginPass(.{
            .action = pass_action,
            .swapchain = sokol.glue.swapchain(),
        });
        defer sg.endPass();
        sg.applyViewport(0, 0, sokol.app.width(), sokol.app.height(), false);

        // render light source (simply re-render sphere at light positions)
        // this looks a bit off as we use the same shader, but it'll make their positions obvious and
        // keeps the codeprint small.
        for (state.lightPositions) |p| {
            const lightPosition = Vec3{ .x = p[0], .y = p[1], .z = p[2] };
            const newPos = lightPosition.add(
                Vec3{
                    .x = std.math.sin(@as(f32, @floatCast(sokol.time.sec(sokol.time.now()))) * 5.0) * 5.0,
                    .y = 0.0,
                    .z = 0.0,
                },
            );
            _ = newPos;
            //             pbrShader.setVec3("lightPositions[" + std::to_string(i) + "]", newPos);
            //             pbrShader.setVec3("lightColors[" + std::to_string(i) + "]", lightColors[i]);
            //
            //             model = glm::mat4(1.0f);
            //             model = glm::translate(model, newPos);
            //             model = glm::scale(model, glm::vec3(0.5f));
            //             pbrShader.setMat4("model", model);
            //             pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
            //             renderSphere();
        }

        // render skybox (render as last to prevent overdraw)
        if (state.env_cubemap) |cubemap| {
            sg.applyPipeline(state.background_pip);
            const vs = background_shader.VsParams{
                .view = view.m,
                .projection = projection.m,
            };
            sg.applyUniforms(.VS, pbr_shader.SLOT_vs_params, sg.asRange(&vs));
            var bind = sg.Bindings{
            };
            bind.vertex_buffers[0] = cubemap.vbo;
            bind.fs.images[background_shader.SLOT_environmentMap] = cubemap.image;
            bind.fs.samplers[background_shader.SLOT_environmentMapSampler] = cubemap.sampler;
            sg.applyBindings(bind);
            sg.draw(0, 36, 1);
        }
    }
}

export fn event(e: [*c]const sokol.app.Event) void {
    switch (e.*.type) {
        .MOUSE_DOWN => {
            switch (e.*.mouse_button) {
                .LEFT => {
                    state.input.mouse_left = true;
                },
                .RIGHT => {
                    state.input.mouse_right = true;
                },
                .MIDDLE => {
                    state.input.mouse_middle = true;
                },
                .INVALID => {},
            }
        },
        .MOUSE_UP => {
            switch (e.*.mouse_button) {
                .LEFT => {
                    state.input.mouse_left = false;
                },
                .RIGHT => {
                    state.input.mouse_right = false;
                },
                .MIDDLE => {
                    state.input.mouse_middle = false;
                },
                .INVALID => {},
            }
        },
        .MOUSE_MOVE => {
            state.input.mouse_x = e.*.mouse_x;
            state.input.mouse_y = e.*.mouse_y;
        },
        .MOUSE_SCROLL => {
            state.input.mouse_wheel = e.*.scroll_y;
        },
        else => {},
    }
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sokol.app.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = SCR_WIDTH,
        .height = SCR_HEIGHT,
        .high_dpi = true,
        .window_title = TITLE,
        .logger = .{ .func = sokol.log.func },
    });
}
