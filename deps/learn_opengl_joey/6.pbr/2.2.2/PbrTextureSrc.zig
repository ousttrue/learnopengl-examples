const PbrTextureSrc = @This();
albedo: [:0]const u8,
normal: [:0]const u8,
metallic: [:0]const u8,
roughness: [:0]const u8,
ao: [:0]const u8,

pub const iron = PbrTextureSrc{
    .albedo = "resources/textures/pbr/rusted_iron/albedo.png",
    .normal = "resources/textures/pbr/rusted_iron/normal.png",
    .metallic = "resources/textures/pbr/rusted_iron/metallic.png",
    .roughness = "resources/textures/pbr/rusted_iron/roughness.png",
    .ao = "resources/textures/pbr/rusted_iron/ao.png",
};

pub const gold = PbrTextureSrc{
    .albedo = "resources/textures/pbr/gold/albedo.png",
    .normal = "resources/textures/pbr/gold/normal.png",
    .metallic = "resources/textures/pbr/gold/metallic.png",
    .roughness = "resources/textures/pbr/gold/roughness.png",
    .ao = "resources/textures/pbr/gold/ao.png",
};

pub const grass = PbrTextureSrc{
    .albedo = "resources/textures/pbr/grass/albedo.png",
    .normal = "resources/textures/pbr/grass/normal.png",
    .metallic = "resources/textures/pbr/grass/metallic.png",
    .roughness = "resources/textures/pbr/grass/roughness.png",
    .ao = "resources/textures/pbr/grass/ao.png",
};

pub const plastic = PbrTextureSrc{
    .albedo = "resources/textures/pbr/plastic/albedo.png",
    .normal = "resources/textures/pbr/plastic/normal.png",
    .metallic = "resources/textures/pbr/plastic/metallic.png",
    .roughness = "resources/textures/pbr/plastic/roughness.png",
    .ao = "resources/textures/pbr/plastic/ao.png",
};

pub const wall = PbrTextureSrc{
    .albedo = "resources/textures/pbr/wall/albedo.png",
    .normal = "resources/textures/pbr/wall/normal.png",
    .metallic = "resources/textures/pbr/wall/metallic.png",
    .roughness = "resources/textures/pbr/wall/roughness.png",
    .ao = "resources/textures/pbr/wall/ao.png",
};
