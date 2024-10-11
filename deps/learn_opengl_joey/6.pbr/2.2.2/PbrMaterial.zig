const sokol = @import("sokol");
const sg = sokol.gfx;
const pbr_shader = @import("pbr.glsl.zig");
const Texture = @import("Texture.zig");

pub const PbrMaterial = @This();
albedo: Texture,
normal: Texture,
metallic: Texture,
roughness: Texture,
ao: Texture,

pub fn bind(m: @This(), bindings: *sg.Bindings) void {
    bindings.fs.images[pbr_shader.SLOT_albedoMap] = m.albedo.image;
    bindings.fs.samplers[pbr_shader.SLOT_albedoMapSampler] = m.albedo.sampler;
    bindings.fs.images[pbr_shader.SLOT_normalMap] = m.albedo.image;
    bindings.fs.samplers[pbr_shader.SLOT_normalMapSampler] = m.albedo.sampler;
    bindings.fs.images[pbr_shader.SLOT_metallicMap] = m.albedo.image;
    bindings.fs.samplers[pbr_shader.SLOT_metallicMapSampler] = m.albedo.sampler;
    bindings.fs.images[pbr_shader.SLOT_roughnessMap] = m.albedo.image;
    bindings.fs.samplers[pbr_shader.SLOT_roughnessMapSampler] = m.albedo.sampler;
    bindings.fs.images[pbr_shader.SLOT_aoMap] = m.albedo.image;
    bindings.fs.samplers[pbr_shader.SLOT_aoMapSampler] = m.albedo.sampler;
}

const IbrMaterial = struct {
    //         // bind pre-computed IBL data
    //         glActiveTexture(GL_TEXTURE0);
    //         glBindTexture(GL_TEXTURE_CUBE_MAP, irradianceMap);
    //         glActiveTexture(GL_TEXTURE1);
    //         glBindTexture(GL_TEXTURE_CUBE_MAP, prefilterMap);
    //         glActiveTexture(GL_TEXTURE2);
    //         glBindTexture(GL_TEXTURE_2D, brdfLUTTexture);
};
