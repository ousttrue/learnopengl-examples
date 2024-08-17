const std = @import("std");
const builtin = @import("builtin");

pub const Deps = struct {
    dep_sokol: *std.Build.Dependency,
    dep_cimgui: *std.Build.Dependency,
    helper: *std.Build.Module,
    szmath: *std.Build.Module,
    stb_image: *std.Build.Module,
    lopgl: *std.Build.Module,
    dbgui: *std.Build.Module,
    util_camera: *std.Build.Module,

    pub fn init(
        b: *std.Build,
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
    ) @This() {
        var deps = @This(){
            .dep_sokol = b.dependency("sokol", .{
                .target = target,
                .optimize = optimize,
                .with_sokol_imgui = true,
            }),
            .dep_cimgui = b.dependency("cimgui", .{
                .target = target,
                .optimize = optimize,
            }),
            .helper = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("learn_opengl/sokol_helper/main.zig"),
            }),
            .szmath = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("szmath/math.zig"),
            }),
            .stb_image = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("c/stb_image.zig"),
            }),
            .lopgl = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("learn_opengl/lopgl_app.zig"),
            }),
            .dbgui = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("sokol_examples/libs/dbgui/dbgui.zig"),
            }),
            .util_camera = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .root_source_file = b.path("sokol_examples/libs/util/camera.zig"),
            }),
        };

        // inject the cimgui header search path into the sokol C library compile step
        const cimgui_root = deps.dep_cimgui.namedWriteFiles("cimgui").getDirectory();
        deps.dep_sokol.artifact("sokol_clib").addIncludePath(cimgui_root);
        deps.helper.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.lopgl.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.lopgl.addImport("szmath", deps.szmath);
        deps.dbgui.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.util_camera.addImport("sokol", deps.dep_sokol.module("sokol"));
        deps.util_camera.addImport("szmath", deps.szmath);

        return deps;
    }

    pub fn inject_dependencies(self: @This(), compile: *std.Build.Step.Compile) void {
        compile.root_module.addImport("sokol", self.dep_sokol.module("sokol"));
        compile.root_module.addImport("sokol_helper", self.helper);
        compile.root_module.addImport("szmath", self.szmath);
        compile.root_module.addImport("stb_image", self.stb_image);
        compile.root_module.addImport("cimgui", self.dep_cimgui.module("cimgui"));
        compile.root_module.addImport("lopgl", self.lopgl);
        compile.root_module.addImport("dbgui", self.dbgui);
        compile.root_module.addImport("util_camera", self.util_camera);
        // compile.linkLibC();
    }
};
