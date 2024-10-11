// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/6.pbr/2.2.2.ibl_specular_textured/ibl_specular_textured.cpp
const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const pbr_shader = @import("pbr.glsl.zig");
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
const FrameBuffer = @import("FrameBuffer.zig");
// const EnvCubemap = @import("EnvCubemap.zig");

// settings
const SCR_WIDTH = 1280;
const SCR_HEIGHT = 720;
const TITLE = "6.2.2.2 ibl_specular_textured";
var fetch_buffer: [1024 * 1024 * 10]u8 = undefined;

const state = struct {
    var pbr_pip = sg.Pipeline{};
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

        const cubemap = FrameBuffer.initCubemap(512);

        cubemap.render(texture);

        std.debug.print("loaded\n", .{});
    } else if (response.*.failed) {
        std.debug.print("[hdr_texture_callback] failed\n", .{});
    }
}

export fn frame() void {
    sokol.fetch.dowork();

    state.input.screen_width = sokol.app.widthf();
    state.input.screen_height = sokol.app.heightf();
    state.orbit.frame(state.input);
    state.input.mouse_wheel = 0;
    const view = state.orbit.viewMatrix();
    const projection = state.orbit.projectionMatrix();
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

    // initialize static shader uniforms before rendering
    // --------------------------------------------------
    //     glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
    //     pbrShader.use();
    //     pbrShader.setMat4("projection", projection);
    //     backgroundShader.use();
    //     backgroundShader.setMat4("projection", projection);
    //
    //     // then before rendering, configure the viewport to the original framebuffer's screen dimensions
    //     int scrWidth, scrHeight;
    //     glfwGetFramebufferSize(window, &scrWidth, &scrHeight);
    //     glViewport(0, 0, scrWidth, scrHeight);

    defer sg.commit();
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

        if (state.iron) |material| {
            // iron
            sg.applyPipeline(state.pbr_pip);
            const model = Mat4.makeTranslation(.{ .x = -5.0, .y = 0.0, .z = 2.0 });
            const vs = pbr_shader.VsParams{
                .model = model.m,
                .view = view.m,
                .projection = projection.m,
                .normalMatrixCol0 = .{ 1, 0, 0 },
                .normalMatrixCol1 = .{ 0, 1, 0 },
                .normalMatrixCol2 = .{ 0, 0, 1 },
            };
            sg.applyUniforms(.VS, pbr_shader.SLOT_vs_params, sg.asRange(&vs));
            sg.applyUniforms(.FS, pbr_shader.SLOT_fs_params, sg.asRange(&fs));
            var bind = sg.Bindings{};
            state.sphere.bind(&bind);
            material.bind(&bind);
            sg.applyBindings(bind);
            sg.draw(0, state.sphere.index_count, 1);
        }

        if (state.gold) |material| {
            _ = material;
            //         // gold
            //         glActiveTexture(GL_TEXTURE3);
            //         glBindTexture(GL_TEXTURE_2D, goldAlbedoMap);
            //         glActiveTexture(GL_TEXTURE4);
            //         glBindTexture(GL_TEXTURE_2D, goldNormalMap);
            //         glActiveTexture(GL_TEXTURE5);
            //         glBindTexture(GL_TEXTURE_2D, goldMetallicMap);
            //         glActiveTexture(GL_TEXTURE6);
            //         glBindTexture(GL_TEXTURE_2D, goldRoughnessMap);
            //         glActiveTexture(GL_TEXTURE7);
            //         glBindTexture(GL_TEXTURE_2D, goldAOMap);
            //
            //         model = glm::mat4(1.0f);
            //         model = glm::translate(model, glm::vec3(-3.0, 0.0, 2.0));
            //         pbrShader.setMat4("model", model);
            //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
            //         renderSphere();
            //
        }

        if (state.grass) |material| {
            _ = material;
            //         // grass
            //         glActiveTexture(GL_TEXTURE3);
            //         glBindTexture(GL_TEXTURE_2D, grassAlbedoMap);
            //         glActiveTexture(GL_TEXTURE4);
            //         glBindTexture(GL_TEXTURE_2D, grassNormalMap);
            //         glActiveTexture(GL_TEXTURE5);
            //         glBindTexture(GL_TEXTURE_2D, grassMetallicMap);
            //         glActiveTexture(GL_TEXTURE6);
            //         glBindTexture(GL_TEXTURE_2D, grassRoughnessMap);
            //         glActiveTexture(GL_TEXTURE7);
            //         glBindTexture(GL_TEXTURE_2D, grassAOMap);
            //
            //         model = glm::mat4(1.0f);
            //         model = glm::translate(model, glm::vec3(-1.0, 0.0, 2.0));
            //         pbrShader.setMat4("model", model);
            //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
            //         renderSphere();
            //
        }

        if (state.plastic) |material| {
            _ = material;
            //         // plastic
            //         glActiveTexture(GL_TEXTURE3);
            //         glBindTexture(GL_TEXTURE_2D, plasticAlbedoMap);
            //         glActiveTexture(GL_TEXTURE4);
            //         glBindTexture(GL_TEXTURE_2D, plasticNormalMap);
            //         glActiveTexture(GL_TEXTURE5);
            //         glBindTexture(GL_TEXTURE_2D, plasticMetallicMap);
            //         glActiveTexture(GL_TEXTURE6);
            //         glBindTexture(GL_TEXTURE_2D, plasticRoughnessMap);
            //         glActiveTexture(GL_TEXTURE7);
            //         glBindTexture(GL_TEXTURE_2D, plasticAOMap);
            //
            //         model = glm::mat4(1.0f);
            //         model = glm::translate(model, glm::vec3(1.0, 0.0, 2.0));
            //         pbrShader.setMat4("model", model);
            //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
            //         renderSphere();
            //
        }

        if (state.wall) |material| {
            _ = material;
            //         // wall
            //         glActiveTexture(GL_TEXTURE3);
            //         glBindTexture(GL_TEXTURE_2D, wallAlbedoMap);
            //         glActiveTexture(GL_TEXTURE4);
            //         glBindTexture(GL_TEXTURE_2D, wallNormalMap);
            //         glActiveTexture(GL_TEXTURE5);
            //         glBindTexture(GL_TEXTURE_2D, wallMetallicMap);
            //         glActiveTexture(GL_TEXTURE6);
            //         glBindTexture(GL_TEXTURE_2D, wallRoughnessMap);
            //         glActiveTexture(GL_TEXTURE7);
            //         glBindTexture(GL_TEXTURE_2D, wallAOMap);
            //
            //         model = glm::mat4(1.0f);
            //         model = glm::translate(model, glm::vec3(3.0, 0.0, 2.0));
            //         pbrShader.setMat4("model", model);
            //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
            //         renderSphere();
            //
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
    }

    // render skybox (render as last to prevent overdraw)
    //         backgroundShader.use();
    //
    //         backgroundShader.setMat4("view", view);
    //         glActiveTexture(GL_TEXTURE0);
    //         glBindTexture(GL_TEXTURE_CUBE_MAP, envCubemap);
    //         //glBindTexture(GL_TEXTURE_CUBE_MAP, irradianceMap); // display irradiance map
    //         //glBindTexture(GL_TEXTURE_CUBE_MAP, prefilterMap); // display prefilter map
    //         renderCube();

    // render BRDF map to screen
    //brdfShader.Use();
    //renderQuad();
}

// // renderCube() renders a 1x1 3D cube in NDC.
// // -------------------------------------------------
// unsigned int cubeVAO = 0;
// unsigned int cubeVBO = 0;
// void renderCube()
// {
//     // initialize (if necessary)
//     if (cubeVAO == 0)
//     {
//         float vertices[] = {
//             // back face
//             -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
//              1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 1.0f, // top-right
//              1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 0.0f, // bottom-right
//              1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 1.0f, // top-right
//             -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
//             -1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 1.0f, // top-left
//             // front face
//             -1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 0.0f, // bottom-left
//              1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 0.0f, // bottom-right
//              1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 1.0f, // top-right
//              1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 1.0f, // top-right
//             -1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 1.0f, // top-left
//             -1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 0.0f, // bottom-left
//             // left face
//             -1.0f,  1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-right
//             -1.0f,  1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 1.0f, // top-left
//             -1.0f, -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-left
//             -1.0f, -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-left
//             -1.0f, -1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 0.0f, // bottom-right
//             -1.0f,  1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-right
//             // right face
//              1.0f,  1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-left
//              1.0f, -1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-right
//              1.0f,  1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 1.0f, // top-right
//              1.0f, -1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-right
//              1.0f,  1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-left
//              1.0f, -1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 0.0f, // bottom-left
//             // bottom face
//             -1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 1.0f, // top-right
//              1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 1.0f, // top-left
//              1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 0.0f, // bottom-left
//              1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 0.0f, // bottom-left
//             -1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 0.0f, // bottom-right
//             -1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 1.0f, // top-right
//             // top face
//             -1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 1.0f, // top-left
//              1.0f,  1.0f , 1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 0.0f, // bottom-right
//              1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 1.0f, // top-right
//              1.0f,  1.0f,  1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 0.0f, // bottom-right
//             -1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 1.0f, // top-left
//             -1.0f,  1.0f,  1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 0.0f  // bottom-left
//         };
//         glGenVertexArrays(1, &cubeVAO);
//         glGenBuffers(1, &cubeVBO);
//         // fill buffer
//         glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
//         glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//         // link vertex attributes
//         glBindVertexArray(cubeVAO);
//         glEnableVertexAttribArray(0);
//         glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
//         glEnableVertexAttribArray(1);
//         glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
//         glEnableVertexAttribArray(2);
//         glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
//         glBindBuffer(GL_ARRAY_BUFFER, 0);
//         glBindVertexArray(0);
//     }
//     // render Cube
//     glBindVertexArray(cubeVAO);
//     glDrawArrays(GL_TRIANGLES, 0, 36);
//     glBindVertexArray(0);
// }

// // renderQuad() renders a 1x1 XY quad in NDC
// // -----------------------------------------
// unsigned int quadVAO = 0;
// unsigned int quadVBO;
// void renderQuad()
// {
//     if (quadVAO == 0)
//     {
//         float quadVertices[] = {
//             // positions        // texture Coords
//             -1.0f,  1.0f, 0.0f, 0.0f, 1.0f,
//             -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
//              1.0f,  1.0f, 0.0f, 1.0f, 1.0f,
//              1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
//         };
//         // setup plane VAO
//         glGenVertexArrays(1, &quadVAO);
//         glGenBuffers(1, &quadVBO);
//         glBindVertexArray(quadVAO);
//         glBindBuffer(GL_ARRAY_BUFFER, quadVBO);
//         glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);
//         glEnableVertexAttribArray(0);
//         glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
//         glEnableVertexAttribArray(1);
//         glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
//     }
//     glBindVertexArray(quadVAO);
//     glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//     glBindVertexArray(0);
// }

// // utility function for loading a 2D texture from file
// // ---------------------------------------------------
// unsigned int loadTexture(char const * path)
// {
//     unsigned int textureID;
//     glGenTextures(1, &textureID);
//
//     int width, height, nrComponents;
//     unsigned char *data = stbi_load(path, &width, &height, &nrComponents, 0);
//     if (data)
//     {
//         GLenum format;
//         if (nrComponents == 1)
//             format = GL_RED;
//         else if (nrComponents == 3)
//             format = GL_RGB;
//         else if (nrComponents == 4)
//             format = GL_RGBA;
//
//         glBindTexture(GL_TEXTURE_2D, textureID);
//         glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
//         glGenerateMipmap(GL_TEXTURE_2D);
//
//         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
//         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//
//         stbi_image_free(data);
//     }
//     else
//     {
//         std::cout << "Texture failed to load at path: " << path << std::endl;
//         stbi_image_free(data);
//     }
//
//     return textureID;
// }

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
