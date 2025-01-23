const sokol = @import("sokol");
const sg = sokol.gfx;
const pbr_shader = @import("pbr.glsl.zig");
const Texture = @import("Texture.zig");
const PbrTextureSrc = @import("PbrTextureSrc.zig");

pub const PbrMaterial = @This();
albedo: Texture,
normal: Texture,
metallic: Texture,
roughness: Texture,
ao: Texture,

pub fn bind(m: @This(), bindings: *sg.Bindings) void {
    bindings.images[pbr_shader.IMG_albedoMap] = m.albedo.image;
    bindings.samplers[pbr_shader.SMP_albedoMapSampler] = m.albedo.sampler;
    bindings.images[pbr_shader.IMG_normalMap] = m.normal.image;
    bindings.samplers[pbr_shader.SMP_normalMapSampler] = m.normal.sampler;
    bindings.images[pbr_shader.IMG_metallicMap] = m.metallic.image;
    bindings.samplers[pbr_shader.SMP_metallicMapSampler] = m.metallic.sampler;
    bindings.images[pbr_shader.IMG_roughnessMap] = m.roughness.image;
    bindings.samplers[pbr_shader.SMP_roughnessMapSampler] = m.roughness.sampler;
    bindings.images[pbr_shader.IMG_aoMap] = m.ao.image;
    bindings.samplers[pbr_shader.SMP_aoMapSampler] = m.ao.sampler;
}
