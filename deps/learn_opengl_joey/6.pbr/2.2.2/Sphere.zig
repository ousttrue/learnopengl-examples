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
