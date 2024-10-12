const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const rowmath = @import("rowmath");
const Vec3 = rowmath.Vec3;
const Vec2 = rowmath.Vec2;
const Sphere = @This();

vertex_buffer: sg.Buffer,
index_buffer: sg.Buffer,
index_count: u32,

const X_SEGMENTS = 64;
const Y_SEGMENTS = 64;

pub fn init(allocator: std.mem.Allocator) !@This() {
    var positions = std.ArrayList(Vec3).init(allocator);
    defer positions.deinit();
    var uv = std.ArrayList(Vec2).init(allocator);
    defer uv.deinit();
    var normals = std.ArrayList(Vec3).init(allocator);
    defer normals.deinit();

    for (0..X_SEGMENTS + 1) |x| {
        for (0..Y_SEGMENTS + 1) |y| {
            const xSegment: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(X_SEGMENTS));
            const ySegment: f32 = @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(Y_SEGMENTS));
            const xPos = std.math.cos(xSegment * 2.0 * std.math.pi) * std.math.sin(ySegment * std.math.pi);
            const yPos = std.math.cos(ySegment * std.math.pi);
            const zPos = std.math.sin(xSegment * 2.0 * std.math.pi) * std.math.sin(ySegment * std.math.pi);
            try positions.append(.{ .x = xPos, .y = yPos, .z = zPos });
            try uv.append(.{ .x = xSegment, .y = ySegment });
            try normals.append(.{ .x = xPos, .y = yPos, .z = zPos });
        }
    }

    var indices = std.ArrayList(u16).init(allocator);
    defer indices.deinit();
    var oddRow = false;
    for (0..Y_SEGMENTS) |y| {
        if (!oddRow) // even rows: y == 0, y == 2; and so on
        {
            for (0..X_SEGMENTS + 1) |x| {
                try indices.append(@intCast(y * (X_SEGMENTS + 1) + x));
                try indices.append(@intCast((y + 1) * (X_SEGMENTS + 1) + x));
            }
        } else {
            var x: i32 = X_SEGMENTS;
            while (x >= 0) : (x -= 1) {
                try indices.append(@intCast((y + 1) * (X_SEGMENTS + 1) + @as(u32, @intCast(x))));
                try indices.append(@intCast(y * (X_SEGMENTS + 1) + @as(u32, @intCast(x))));
            }
        }
        oddRow = !oddRow;
    }

    var data = std.ArrayList(f32).init(allocator);
    for (0..positions.items.len) |i| {
        try data.append(positions.items[i].x);
        try data.append(positions.items[i].y);
        try data.append(positions.items[i].z);
        if (normals.items.len > 0) {
            try data.append(normals.items[i].x);
            try data.append(normals.items[i].y);
            try data.append(normals.items[i].z);
        }
        if (uv.items.len > 0) {
            try data.append(uv.items[i].x);
            try data.append(uv.items[i].y);
        }
    }

    return .{
        .vertex_buffer = sg.makeBuffer(.{
            .data = sg.asRange(data.items),
            .label = "vertices",
        }),
        .index_buffer = sg.makeBuffer(.{
            .data = sg.asRange(indices.items),
            .label = "indices",
            .type = .INDEXBUFFER,
        }),
        .index_count = @intCast(indices.items.len),
    };
}

pub fn bind(self: @This(), bindings: *sg.Bindings) void {
    bindings.index_buffer = self.index_buffer;
    bindings.vertex_buffers[0] = self.vertex_buffer;
}

pub fn render_shperes()void
{
    // const campos = state.orbit.camera.transform.translation;
    // const fs = pbr_shader.FsParams{
    //     .lightColors = state.lightColors,
    //     .lightPositions = state.lightPositions,
    //     .camPos = .{
    //         campos.x,
    //         campos.y,
    //         campos.z,
    //     },
    // };

        // if (state.iron) |material| {
        //     // iron
        //     sg.applyPipeline(state.pbr_pip);
        //     const model = Mat4.makeTranslation(.{ .x = -5.0, .y = 0.0, .z = 2.0 });
        //     const vs = pbr_shader.VsParams{
        //         .model = model.m,
        //         .view = view.m,
        //         .projection = projection.m,
        //         .normalMatrixCol0 = .{ 1, 0, 0 },
        //         .normalMatrixCol1 = .{ 0, 1, 0 },
        //         .normalMatrixCol2 = .{ 0, 0, 1 },
        //     };
        //     sg.applyUniforms(.VS, pbr_shader.SLOT_vs_params, sg.asRange(&vs));
        //     sg.applyUniforms(.FS, pbr_shader.SLOT_fs_params, sg.asRange(&fs));
        //     var bind = sg.Bindings{};
        //     state.sphere.bind(&bind);
        //     material.bind(&bind);
        //     sg.applyBindings(bind);
        //     sg.draw(0, state.sphere.index_count, 1);
        // }
        //
        // if (state.gold) |material| {
        //     _ = material;
        //     //         // gold
        //     //         glActiveTexture(GL_TEXTURE3);
        //     //         glBindTexture(GL_TEXTURE_2D, goldAlbedoMap);
        //     //         glActiveTexture(GL_TEXTURE4);
        //     //         glBindTexture(GL_TEXTURE_2D, goldNormalMap);
        //     //         glActiveTexture(GL_TEXTURE5);
        //     //         glBindTexture(GL_TEXTURE_2D, goldMetallicMap);
        //     //         glActiveTexture(GL_TEXTURE6);
        //     //         glBindTexture(GL_TEXTURE_2D, goldRoughnessMap);
        //     //         glActiveTexture(GL_TEXTURE7);
        //     //         glBindTexture(GL_TEXTURE_2D, goldAOMap);
        //     //
        //     //         model = glm::mat4(1.0f);
        //     //         model = glm::translate(model, glm::vec3(-3.0, 0.0, 2.0));
        //     //         pbrShader.setMat4("model", model);
        //     //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
        //     //         renderSphere();
        //     //
        // }
        //
        // if (state.grass) |material| {
        //     _ = material;
        //     //         // grass
        //     //         glActiveTexture(GL_TEXTURE3);
        //     //         glBindTexture(GL_TEXTURE_2D, grassAlbedoMap);
        //     //         glActiveTexture(GL_TEXTURE4);
        //     //         glBindTexture(GL_TEXTURE_2D, grassNormalMap);
        //     //         glActiveTexture(GL_TEXTURE5);
        //     //         glBindTexture(GL_TEXTURE_2D, grassMetallicMap);
        //     //         glActiveTexture(GL_TEXTURE6);
        //     //         glBindTexture(GL_TEXTURE_2D, grassRoughnessMap);
        //     //         glActiveTexture(GL_TEXTURE7);
        //     //         glBindTexture(GL_TEXTURE_2D, grassAOMap);
        //     //
        //     //         model = glm::mat4(1.0f);
        //     //         model = glm::translate(model, glm::vec3(-1.0, 0.0, 2.0));
        //     //         pbrShader.setMat4("model", model);
        //     //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
        //     //         renderSphere();
        //     //
        // }
        //
        // if (state.plastic) |material| {
        //     _ = material;
        //     //         // plastic
        //     //         glActiveTexture(GL_TEXTURE3);
        //     //         glBindTexture(GL_TEXTURE_2D, plasticAlbedoMap);
        //     //         glActiveTexture(GL_TEXTURE4);
        //     //         glBindTexture(GL_TEXTURE_2D, plasticNormalMap);
        //     //         glActiveTexture(GL_TEXTURE5);
        //     //         glBindTexture(GL_TEXTURE_2D, plasticMetallicMap);
        //     //         glActiveTexture(GL_TEXTURE6);
        //     //         glBindTexture(GL_TEXTURE_2D, plasticRoughnessMap);
        //     //         glActiveTexture(GL_TEXTURE7);
        //     //         glBindTexture(GL_TEXTURE_2D, plasticAOMap);
        //     //
        //     //         model = glm::mat4(1.0f);
        //     //         model = glm::translate(model, glm::vec3(1.0, 0.0, 2.0));
        //     //         pbrShader.setMat4("model", model);
        //     //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
        //     //         renderSphere();
        //     //
        // }
        //
        // if (state.wall) |material| {
        //     _ = material;
        //     //         // wall
        //     //         glActiveTexture(GL_TEXTURE3);
        //     //         glBindTexture(GL_TEXTURE_2D, wallAlbedoMap);
        //     //         glActiveTexture(GL_TEXTURE4);
        //     //         glBindTexture(GL_TEXTURE_2D, wallNormalMap);
        //     //         glActiveTexture(GL_TEXTURE5);
        //     //         glBindTexture(GL_TEXTURE_2D, wallMetallicMap);
        //     //         glActiveTexture(GL_TEXTURE6);
        //     //         glBindTexture(GL_TEXTURE_2D, wallRoughnessMap);
        //     //         glActiveTexture(GL_TEXTURE7);
        //     //         glBindTexture(GL_TEXTURE_2D, wallAOMap);
        //     //
        //     //         model = glm::mat4(1.0f);
        //     //         model = glm::translate(model, glm::vec3(3.0, 0.0, 2.0));
        //     //         pbrShader.setMat4("model", model);
        //     //         pbrShader.setMat3("normalMatrix", glm::transpose(glm::inverse(glm::mat3(model))));
        //     //         renderSphere();
        //     //
        // }


}
