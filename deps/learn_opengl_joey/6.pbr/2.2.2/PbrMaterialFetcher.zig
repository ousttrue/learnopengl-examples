const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;
const PbrTextureSrc = @import("PbrTextureSrc.zig");
const PbrMaterial = @import("PbrMaterial.zig");
const Texture = @import("Texture.zig");
pub const PbrMaterialFetcher = @This();
pub const OnLoad = fn (pbr: PbrMaterial) void;

src: PbrTextureSrc,
albedo: Texture = undefined,
normal: Texture = undefined,
metallic: Texture = undefined,
roughness: Texture = undefined,
ao: Texture = undefined,
task: usize = 0,
fetch_buffer: []u8 = undefined,
on_load: *const OnLoad,

pub fn fetch(
    self: *@This(),
    fetch_buffer: []u8,
) void {
    self.fetch_buffer = fetch_buffer;
    self.fetchPath(self.src.albedo);
}

fn fetchPath(self: *@This(), path: [:0]const u8) void {
    const ptr: usize = @intFromPtr(self);
    std.debug.print("fetch {s}...{}\n", .{ path, ptr });
    _ = sokol.fetch.send(.{
        .path = &path[0],
        .callback = fetch_callback,
        .buffer = sokol.fetch.asRange(self.fetch_buffer),
        .user_data = sokol.fetch.asRange(&ptr),
    });
}

export fn fetch_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        const _p: *const usize = @ptrCast(@alignCast(response.*.user_data));
        const p = _p.*;
        std.debug.print("address {}\n", .{p});
        var self: *PbrMaterialFetcher = @ptrFromInt(p);
        self.onFetched(response.*.data.ptr, response.*.data.size);
    } else if (response.*.failed) {
        std.debug.print("[PbrMaterialFetcher. fetch_callback] failed\n", .{});
    }
}

fn onFetched(self: *@This(), p: ?*const anyopaque, size: usize) void {
    switch (self.task) {
        0 => {
            if (Texture.load(p, size)) |texture| {
                std.debug.print("load albedo: ok\n", .{});
                self.albedo = texture;
                self.task += 1;
                self.fetchPath(self.src.normal);
            } else |_| {
                std.debug.print("load albedo: failed\n", .{});
            }
        },
        1 => {
            if (Texture.load(p, size)) |texture| {
                std.debug.print("load normal: ok\n", .{});
                self.normal = texture;
                self.task += 1;
                self.fetchPath(self.src.metallic);
            } else |_| {
                std.debug.print("load normal: failed\n", .{});
            }
        },
        2 => {
            if (Texture.load(p, size)) |texture| {
                std.debug.print("load metallic: ok\n", .{});
                self.metallic = texture;
                self.task += 1;
                self.fetchPath(self.src.roughness);
            } else |_| {
                std.debug.print("load metallic: failed\n", .{});
            }
        },
        3 => {
            if (Texture.load(p, size)) |texture| {
                std.debug.print("load roughness: ok\n", .{});
                self.roughness = texture;
                self.task += 1;
                self.fetchPath(self.src.ao);
            } else |_| {
                std.debug.print("load roughness: failed\n", .{});
            }
        },
        4 => {
            if (Texture.load(p, size)) |texture| {
                std.debug.print("load ao: ok\n", .{});
                self.ao = texture;
                self.task += 1;
                self.on_load(.{
                    .albedo = self.albedo,
                    .normal = self.normal,
                    .metallic = self.metallic,
                    .roughness = self.roughness,
                    .ao = self.ao,
                });
            } else |_| {
                std.debug.print("load ao: failed\n", .{});
            }
        },
        else => {
            unreachable;
        },
    }
}
