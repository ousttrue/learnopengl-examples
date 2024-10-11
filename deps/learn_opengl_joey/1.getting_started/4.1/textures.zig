// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/4.1.textures/textures.cpp
const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const shader = @import("textures.glsl.zig");
const Texture = @import("Texture.zig");

// settings
const SCR_WIDTH = 800;
const SCR_HEIGHT = 600;
const TITLE = "1.4.1 textures";
const TEXTURE = "resources/textures/container.jpg";

const state = struct {
    var pip = sg.Pipeline{};
    var vertex_buffer = sg.Buffer{};
    var index_buffer = sg.Buffer{};
    var texture: ?Texture = null;
};

var fetch_buffer: [512 * 1024]u8 = undefined;

export fn init() void {
    sg.setup(.{
        .environment = sokol.glue.environment(),
        .logger = .{ .func = sokol.log.func },
    });

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
        .type = .INDEXBUFFER,
    });

    var pip_desc = sg.PipelineDesc{
        .shader = sg.makeShader(shader.texturesShaderDesc(sg.queryBackend())),
        .label = "textures",
        .index_type = .UINT16,
    };
    pip_desc.layout.attrs[shader.ATTR_vs_aPos].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_aColor].format = .FLOAT3;
    pip_desc.layout.attrs[shader.ATTR_vs_aTexCoord].format = .FLOAT2;
    state.pip = sg.makePipeline(pip_desc);

    sokol.fetch.setup(.{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
    });
    _ = sokol.fetch.send(.{
        .path = TEXTURE,
        .callback = fetch_callback,
        .buffer = sokol.fetch.asRange(&fetch_buffer),
    });
}

export fn fetch_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        if (Texture.load(response.*.data.ptr, response.*.data.size)) |texture| {
            state.texture = texture;
        } else |_| {
            std.debug.print("Texture.load failed\n", .{});
        }
    } else if (response.*.failed) {
        std.debug.print("fetch failed\n", .{});
    }
}

export fn frame() void {
    sokol.fetch.dowork();
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

        if (state.texture) |texture| {
            sg.applyPipeline(state.pip);
            var bind = sg.Bindings{};
            bind.index_buffer = state.index_buffer;
            bind.vertex_buffers[0] = state.vertex_buffer;
            bind.fs.images[shader.SLOT_texture1] = texture.image;
            bind.fs.samplers[shader.SLOT_sampler1] = texture.sampler;
            sg.applyBindings(bind);
            sg.draw(0, 6, 1);
        }
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
        .width = SCR_WIDTH,
        .height = SCR_HEIGHT,
        .high_dpi = true,
        .window_title = TITLE,
    });
}
