const std = @import("std");
const sokol = @import("sokol");
const Image = @import("Image.zig");

const Callback = fn (images: []const Image) void;

var _allocator: std.mem.Allocator = undefined;
var _src: []const []const u8 = undefined;
var _dst: []u8 = undefined;
var _index: usize = 0;

var _images: [6]Image = undefined;
var _image_bytes_size: usize = 0;
var _callback: *const Callback = undefined;

pub fn fetch(
    allocator: std.mem.Allocator,
    src: []const []const u8,
    size: u32,
    on_download: *const Callback,
) !void {
    _allocator = allocator;
    _src = src;
    _image_bytes_size = size * size * 4;
    _dst = try allocator.alloc(u8, _image_bytes_size * 6);
    _callback = on_download;

    fetch_index();
}

fn fetch_index() void {
    std.debug.print("fetch: {s}...\n", .{_src[_index]});
    _ = sokol.fetch.send(.{
        .path = &_src[_index][0],
        .buffer = sokol.fetch.asRange(getRange(_index)),
        .callback = &fetcher_callback,
    });
}

fn getRange(index: usize) []u8 {
    const offset = index * _image_bytes_size;
    return _dst[offset .. offset + _image_bytes_size];
}

export fn fetcher_callback(response: [*c]const sokol.fetch.Response) void {
    if (response.*.fetched) {
        const p: [*]const u8 = @ptrCast(response.*.data.ptr);
        _images[_index] = Image.load(p[0..response.*.data.size], getRange(_index)) catch
            @panic("Image.load");

        _index += 1;
        if (_index >= _src.len) {
            // complete
            defer _allocator.free(_dst);
            _callback(&_images);
        } else {
            fetch_index();
        }
    } else if (response.*.failed) {
        std.debug.print("fetch failed\n", .{});
    }
}
