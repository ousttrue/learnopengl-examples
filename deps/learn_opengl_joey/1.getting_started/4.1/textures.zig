// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/4.1.textures/textures.cpp
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("textures.glsl.zig");

// settings
const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;
const TITLE = "1.4.1 textures";

const state = struct {
    var pip = sg.Pipeline{};
    var vertex_buffer = sg.Buffer{};
    var index_buffer = sg.Buffer{};
};

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });

    var pip_desc = sg.PipelineDesc{
        .shader = sg.makeShader(shader.texturesShaderDesc(sg.queryBackend())),
        .label = "textures",
    };
    pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
    state.pip = sg.makePipeline(pip_desc);

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    const vertices = [_]f32{
        // positions          // colors           // texture coords
        0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top right
        0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom right
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom let
        -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, // top let
    };
    state.vertex_buffer = sg.makeBuffer(.{
        .data = sg.asRange(&vertices),
        .label = "vertices",
    });

    const indices = [_]u16{
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };
    state.index_buffer = sg.makeBuffer(.{
        .data = sg.asRange(&indices),
        .label = "indices",
    });

    //     // load and create a texture
    //     // -------------------------
    //     unsigned int texture;
    //     glGenTextures(1, &texture);
    //     glBindTexture(GL_TEXTURE_2D, texture); // all upcoming GL_TEXTURE_2D operations now have effect on this texture object
    //     // set the texture wrapping parameters
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    //     // set texture filtering parameters
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //     // load image, create texture and generate mipmaps
    //     int width, height, nrChannels;
    //     // The FileSystem::getPath(...) is part of the GitHub repository so we can find files on any IDE/platform; replace it with your own image path.
    //     unsigned char *data = stbi_load(FileSystem::getPath("resources/textures/container.jpg").c_str(), &width, &height, &nrChannels, 0);
    //     if (data)
    //     {
    //         glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
    //         glGenerateMipmap(GL_TEXTURE_2D);
    //     }
    //     else
    //     {
    //         std::cout << "Failed to load texture" << std::endl;
    //     }
    //     stbi_image_free(data);
}

export fn frame() void {
    //         // render
    //         // ------
    //         glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    //         glClear(GL_COLOR_BUFFER_BIT);
    //
    //         // bind Texture
    //         glBindTexture(GL_TEXTURE_2D, texture);
    //
    //         // render container
    //         ourShader.use();
    //         glBindVertexArray(VAO);
    //         glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    //
    //         // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    //         // -------------------------------------------------------------------------------
    //         glfwSwapBuffers(window);
    //         glfwPollEvents();
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sokol.app.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = SCR_WIDTH,
        .height = SCR_HEIGHT,
        .high_dpi = true,
        .window_title = TITLE,
    });
}
