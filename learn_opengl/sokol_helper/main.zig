const sokol = @import("sokol");
const sg = sokol.gfx;

pub fn sg_alloc_image_smp(
    bindings: *sg.StageBindings,
    image_index: usize,
    smp_index: usize,
) void {
    bindings.images[image_index] = sg.allocImage();
    bindings.samplers[smp_index] = sg.allocSampler();
    sg.initSampler(bindings.samplers[smp_index], .{
        .wrap_u = .REPEAT,
        .wrap_v = .REPEAT,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .compare = .NEVER,
    });
}
