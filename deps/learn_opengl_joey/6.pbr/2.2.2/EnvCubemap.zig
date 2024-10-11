const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const tocubemap_shader = @import("equirectangular_to_cubemap.zig");
const rowmath = @import("rowmath");
const FrameBuffer = @import("FrameBuffer.zig");
const FloatTexture = @import("FloatTexture.zig");
const Mat4 = rowmath.Mat4;
const Vec3 = rowmath.Vec3;
pub const EnvCubemap = @This();

fn init(texture: FloatTexture) void {

    // configure global opengl state
    // -----------------------------
    // enable seamless cubemap sampling for lower mip levels in the pre-filter map.
    //     glEnable(GL_TEXTURE_CUBE_MAP_SEAMLESS);

    // pbr: set up projection and view matrices for capturing data onto the 6 cubemap face directions
    // ----------------------------------------------------------------------------------------------
    const captureProjection = Mat4.makePerspective(
        std.math.degreesToRadians(90.0),
        1.0,
        0.1,
        10.0,
    );

    const captureViews = [_]Mat4{
        Mat4.makeLookAt(Vec3.zero, Vec3.right, Vec3.down),
        // glm::lookAt(glm::vec3(0.0, 0.0, 0.0), glm::vec3(-1.0,  0.0,  0.0), glm::vec3(0.0, -1.0,  0.0)),
        // glm::lookAt(glm::vec3(0.0, 0.0, 0.0), glm::vec3( 0.0,  1.0,  0.0), glm::vec3(0.0,  0.0,  1.0)),
        // glm::lookAt(glm::vec3(0.0, 0.0, 0.0), glm::vec3( 0.0, -1.0,  0.0), glm::vec3(0.0,  0.0, -1.0)),
        // glm::lookAt(glm::vec3(0.0, 0.0, 0.0), glm::vec3( 0.0,  0.0,  1.0), glm::vec3(0.0, -1.0,  0.0)),
        // glm::lookAt(glm::vec3(0.0, 0.0, 0.0), glm::vec3( 0.0,  0.0, -1.0), glm::vec3(0.0, -1.0,  0.0))
    };
    _ = captureViews;

    // pbr: convert HDR equirectangular environment map to cubemap equivalent
    // ----------------------------------------------------------------------
    const equirectangularToCubemap_pip = tocubemap_shader_pipeline();
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

        {
            sg.applyPipeline(equirectangularToCubemap_pip);

            var bind = sg.Bindings{};
            bind.fs.images[tocubemap_shader.SLOT_texture1] = texture.image;
            bind.fs.samplers[tocubemap_shader.SLOT_sampler1] = texture.sampler;
            sg.applyBindings(bind);

            var vs_params = tocubemap_shader.VsParams{
                .projection = captureProjection.m,
            };
            for (0..6) |i| {
                vs_params.view = captureViews[i].m;

                sg.beginPass(.{
                    .action = pass_action,
                    .attachments = captureFbo.attachments,
                });
                defer sg.endPass();
                // glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, envCubemap, 0);
                glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

                // renderCube();
            }
            //     glBindTexture(GL_TEXTURE_CUBE_MAP, envCubemap);
            //     glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
        }
    }

    //     // pbr: create an irradiance cubemap, and re-scale capture FBO to irradiance scale.
    //     // --------------------------------------------------------------------------------
    //     unsigned int irradianceMap;
    //     glGenTextures(1, &irradianceMap);
    //     glBindTexture(GL_TEXTURE_CUBE_MAP, irradianceMap);
    //     for (unsigned int i = 0; i < 6; ++i)
    //     {
    //         glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB16F, 32, 32, 0, GL_RGB, GL_FLOAT, nullptr);
    //     }
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //
    //     glBindFramebuffer(GL_FRAMEBUFFER, captureFBO);
    //     glBindRenderbuffer(GL_RENDERBUFFER, captureRBO);
    //     glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, 32, 32);
    //
    //     // pbr: solve diffuse integral by convolution to create an irradiance (cube)map.
    //     // -----------------------------------------------------------------------------
    //     irradianceShader.use();
    //     irradianceShader.setInt("environmentMap", 0);
    //     irradianceShader.setMat4("projection", captureProjection);
    //     glActiveTexture(GL_TEXTURE0);
    //     glBindTexture(GL_TEXTURE_CUBE_MAP, envCubemap);
    //
    //     glViewport(0, 0, 32, 32); // don't forget to configure the viewport to the capture dimensions.
    //     glBindFramebuffer(GL_FRAMEBUFFER, captureFBO);
    //     for (unsigned int i = 0; i < 6; ++i)
    //     {
    //         irradianceShader.setMat4("view", captureViews[i]);
    //         glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, irradianceMap, 0);
    //         glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //
    //         renderCube();
    //     }
    //     glBindFramebuffer(GL_FRAMEBUFFER, 0);
    //
    //     // pbr: create a pre-filter cubemap, and re-scale capture FBO to pre-filter scale.
    //     // --------------------------------------------------------------------------------
    //     unsigned int prefilterMap;
    //     glGenTextures(1, &prefilterMap);
    //     glBindTexture(GL_TEXTURE_CUBE_MAP, prefilterMap);
    //     for (unsigned int i = 0; i < 6; ++i)
    //     {
    //         glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB16F, 128, 128, 0, GL_RGB, GL_FLOAT, nullptr);
    //     }
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); // be sure to set minification filter to mip_linear
    //     glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //     // generate mipmaps for the cubemap so OpenGL automatically allocates the required memory.
    //     glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
    //
    //     // pbr: run a quasi monte-carlo simulation on the environment lighting to create a prefilter (cube)map.
    //     // ----------------------------------------------------------------------------------------------------
    //     prefilterShader.use();
    //     prefilterShader.setInt("environmentMap", 0);
    //     prefilterShader.setMat4("projection", captureProjection);
    //     glActiveTexture(GL_TEXTURE0);
    //     glBindTexture(GL_TEXTURE_CUBE_MAP, envCubemap);
    //
    //     glBindFramebuffer(GL_FRAMEBUFFER, captureFBO);
    //     unsigned int maxMipLevels = 5;
    //     for (unsigned int mip = 0; mip < maxMipLevels; ++mip)
    //     {
    //         // reisze framebuffer according to mip-level size.
    //         unsigned int mipWidth = static_cast<unsigned int>(128 * std::pow(0.5, mip));
    //         unsigned int mipHeight = static_cast<unsigned int>(128 * std::pow(0.5, mip));
    //         glBindRenderbuffer(GL_RENDERBUFFER, captureRBO);
    //         glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, mipWidth, mipHeight);
    //         glViewport(0, 0, mipWidth, mipHeight);
    //
    //         float roughness = (float)mip / (float)(maxMipLevels - 1);
    //         prefilterShader.setFloat("roughness", roughness);
    //         for (unsigned int i = 0; i < 6; ++i)
    //         {
    //             prefilterShader.setMat4("view", captureViews[i]);
    //             glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, prefilterMap, mip);
    //
    //             glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //             renderCube();
    //         }
    //     }
    //     glBindFramebuffer(GL_FRAMEBUFFER, 0);
    //
    //     // pbr: generate a 2D LUT from the BRDF equations used.
    //     // ----------------------------------------------------
    //     unsigned int brdfLUTTexture;
    //     glGenTextures(1, &brdfLUTTexture);
    //
    //     // pre-allocate enough memory for the LUT texture.
    //     glBindTexture(GL_TEXTURE_2D, brdfLUTTexture);
    //     glTexImage2D(GL_TEXTURE_2D, 0, GL_RG16F, 512, 512, 0, GL_RG, GL_FLOAT, 0);
    //     // be sure to set wrapping mode to GL_CLAMP_TO_EDGE
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    //     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //
    //     // then re-configure capture framebuffer object and render screen-space quad with BRDF shader.
    //     glBindFramebuffer(GL_FRAMEBUFFER, captureFBO);
    //     glBindRenderbuffer(GL_RENDERBUFFER, captureRBO);
    //     glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, 512, 512);
    //     glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, brdfLUTTexture, 0);
    //
    //     glViewport(0, 0, 512, 512);
    //     brdfShader.use();
    //     glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //     renderQuad();
    //
    //     glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

fn tocubemap_shader_pipeline() sg.Pipeline {
    const pip_desc = sg.PipelineDesc{
        .label = "tocubemap",
        .shader = sg.makeShader(tocubemap_shader.equirectangularToCubemapShader(
            sg.queryBackend(),
        )),
        // .depth = .{
        //     .write_enabled = true,
        //     .compare = .LESS_EQUAL,
        // },
    };
    // pip_desc.layout.attrs[pbr_shader.ATTR_vs_aPos].format = .FLOAT3;
    // pip_desc.layout.attrs[pbr_shader.ATTR_vs_aNormal].format = .FLOAT3;
    // pip_desc.layout.attrs[pbr_shader.ATTR_vs_aTexCoords].format = .FLOAT2;
    return sg.makePipeline(pip_desc);
}
