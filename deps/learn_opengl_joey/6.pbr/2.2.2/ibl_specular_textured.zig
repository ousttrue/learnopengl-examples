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
const PbrTextureSrc = @import("PbrTextureSrc.zig");
const EnvCubemap = @import("EnvCubemap.zig");
const IrradianceMap = @import("IrradianceMap.zig");
const PrefilterMap = @import("PrefilterMap.zig");
const BrdfLut = @import("BrdfLut.zig");
const PbrMaterialFetcher = @import("PbrMaterialFetcher.zig");

// settings
const SCR_WIDTH = 1280;
const SCR_HEIGHT = 720;
const TITLE = "6.2.2.2 ibl_specular_textured";
var fetch_buffer: [1024 * 1024 * 15]u8 = undefined;

const IbrMaterial = struct {
    irradiance_map: IrradianceMap,
    prefilter_map: PrefilterMap,
    brdf_lut: BrdfLut,

    pub fn bind(m: @This(), bindings: *sg.Bindings) void {
        bindings.images[pbr_shader.IMG_irradianceMap] = m.irradiance_map.image;
        bindings.samplers[pbr_shader.SMP_irradianceMapSampler] = m.irradiance_map.sampler;
        bindings.images[pbr_shader.IMG_prefilterMap] = m.prefilter_map.image;
        bindings.samplers[pbr_shader.SMP_prefilterMapSampler] = m.prefilter_map.sampler;
        bindings.images[pbr_shader.IMG_brdfLUT] = m.brdf_lut.image;
        bindings.samplers[pbr_shader.SMP_brdfLUTSampler] = m.brdf_lut.sampler;
    }
};

const state = struct {
    var pbr_pip = sg.Pipeline{};
    var background_pip = sg.Pipeline{};
    var sphere: Sphere = undefined;

    var iron_fetcher = PbrMaterialFetcher{
        .src = PbrTextureSrc.iron,
        .on_load = on_iron,
    };
    var gold_fetcher = PbrMaterialFetcher{
        .src = PbrTextureSrc.gold,
        .on_load = on_gold,
    };
    var grass_fetcher = PbrMaterialFetcher{
        .src = PbrTextureSrc.grass,
        .on_load = on_grass,
    };
    var plastic_fetcher = PbrMaterialFetcher{
        .src = PbrTextureSrc.plastic,
        .on_load = on_plastic,
    };
    var wall_fetcher = PbrMaterialFetcher{
        .src = PbrTextureSrc.wall,
        .on_load = on_wall,
    };

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
    var ibr_material: ?IbrMaterial = null;
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
            .primitive_type = .TRIANGLE_STRIP,
        };
        pip_desc.layout.attrs[pbr_shader.ATTR_pbr_aPos].format = .FLOAT3;
        pip_desc.layout.attrs[pbr_shader.ATTR_pbr_aNormal].format = .FLOAT3;
        pip_desc.layout.attrs[pbr_shader.ATTR_pbr_aTexCoords].format = .FLOAT2;
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
        pip_desc.layout.attrs[pbr_shader.ATTR_pbr_aPos].format = .FLOAT3;
        pip_desc.layout.buffers[0].stride = 4 * 8;
        state.background_pip = sg.makePipeline(pip_desc);
    }

    state.sphere = Sphere.init(std.heap.c_allocator) catch @panic("Sphere.init");
    std.debug.print("\n\n", .{});

    sokol.fetch.setup(.{
        .max_requests = 1 + 5 * 5,
        .num_channels = 1,
        .num_lanes = 1,
        .logger = .{ .func = sokol.log.func },
    });
    _ = sokol.fetch.send(.{
        .path = "resources/textures/hdr/newport_loft.hdr",
        .callback = hdr_texture_callback,
        .buffer = sokol.fetch.asRange(&fetch_buffer),
    });
    state.iron_fetcher.fetch(&fetch_buffer);
    state.gold_fetcher.fetch(&fetch_buffer);
    state.grass_fetcher.fetch(&fetch_buffer);
    state.plastic_fetcher.fetch(&fetch_buffer);
    state.wall_fetcher.fetch(&fetch_buffer);
}

fn on_iron(pbr: PbrMaterial) void {
    state.iron = pbr;
}
fn on_gold(pbr: PbrMaterial) void {
    state.gold = pbr;
}
fn on_grass(pbr: PbrMaterial) void {
    state.grass = pbr;
}
fn on_plastic(pbr: PbrMaterial) void {
    state.plastic = pbr;
}
fn on_wall(pbr: PbrMaterial) void {
    state.wall = pbr;
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
        state.ibr_material = .{
            .irradiance_map = irradiance_map,
            .prefilter_map = prefilter_map,
            .brdf_lut = brdf_lut,
        };
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

        if (state.ibr_material) |ibl| {
            const campos = state.orbit.camera.transform.translation;
            const fs = pbr_shader.FsParams{
                .lightColors = state.lightColors,
                .lightPositions = state.lightPositions,
                .camPos = .{
                    campos.x,
                    campos.y,
                    campos.z,
                },
            };

            if (state.iron) |pbr| {
                const model = Mat4.makeTranslation(.{ .x = -5.0, .y = 0.0, .z = 2.0 });
                render_pbr_sphere(ibl, pbr, &fs, .{ .view = view, .projection = projection, .model = model });
            }
            if (state.gold) |pbr| {
                const model = Mat4.makeTranslation(.{ .x = -3.0, .y = 0.0, .z = 2.0 });
                render_pbr_sphere(ibl, pbr, &fs, .{ .view = view, .projection = projection, .model = model });
            }
            if (state.grass) |pbr| {
                const model = Mat4.makeTranslation(.{ .x = -1.0, .y = 0.0, .z = 2.0 });
                render_pbr_sphere(ibl, pbr, &fs, .{ .view = view, .projection = projection, .model = model });
            }
            if (state.plastic) |pbr| {
                const model = Mat4.makeTranslation(.{ .x = 1.0, .y = 0.0, .z = 2.0 });
                render_pbr_sphere(ibl, pbr, &fs, .{ .view = view, .projection = projection, .model = model });
            }
            if (state.wall) |pbr| {
                const model = Mat4.makeTranslation(.{ .x = 3.0, .y = 0.0, .z = 2.0 });
                render_pbr_sphere(ibl, pbr, &fs, .{ .view = view, .projection = projection, .model = model });
            }
        }

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
            sg.applyUniforms(pbr_shader.UB_vs_params, sg.asRange(&vs));
            var bind = sg.Bindings{};
            bind.vertex_buffers[0] = cubemap.vbo;
            bind.images[background_shader.IMG_environmentMap] = cubemap.image;
            bind.samplers[background_shader.SMP_environmentMapSampler] = cubemap.sampler;
            sg.applyBindings(bind);
            sg.draw(0, 36, 1);
        }
    }
}

const Opts = struct {
    view: Mat4,
    projection: Mat4,
    model: Mat4,
};
fn render_pbr_sphere(
    ibl: IbrMaterial,
    pbr: PbrMaterial,
    fs: *const pbr_shader.FsParams,
    opts: Opts,
) void {
    sg.applyPipeline(state.pbr_pip);
    var bind = sg.Bindings{};
    state.sphere.bind(&bind);
    ibl.bind(&bind);
    pbr.bind(&bind);
    sg.applyBindings(bind);
    const vs = pbr_shader.VsParams{
        .model = opts.model.m,
        .view = opts.view.m,
        .projection = opts.projection.m,
        .normalMatrixCol0 = .{ 1, 0, 0 },
        .normalMatrixCol1 = .{ 0, 1, 0 },
        .normalMatrixCol2 = .{ 0, 0, 1 },
    };
    sg.applyUniforms(pbr_shader.UB_vs_params, sg.asRange(&vs));
    sg.applyUniforms(pbr_shader.UB_fs_params, sg.asRange(fs));
    sg.draw(0, state.sphere.index_count, 1);
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
