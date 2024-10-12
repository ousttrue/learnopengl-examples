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
    bindings.fs.images[pbr_shader.SLOT_albedoMap] = m.albedo.image;
    bindings.fs.samplers[pbr_shader.SLOT_albedoMapSampler] = m.albedo.sampler;
    bindings.fs.images[pbr_shader.SLOT_normalMap] = m.normal.image;
    bindings.fs.samplers[pbr_shader.SLOT_normalMapSampler] = m.normal.sampler;
    bindings.fs.images[pbr_shader.SLOT_metallicMap] = m.metallic.image;
    bindings.fs.samplers[pbr_shader.SLOT_metallicMapSampler] = m.metallic.sampler;
    bindings.fs.images[pbr_shader.SLOT_roughnessMap] = m.roughness.image;
    bindings.fs.samplers[pbr_shader.SLOT_roughnessMapSampler] = m.roughness.sampler;
    bindings.fs.images[pbr_shader.SLOT_aoMap] = m.ao.image;
    bindings.fs.samplers[pbr_shader.SLOT_aoMapSampler] = m.ao.sampler;
}
