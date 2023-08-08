@ctype vec3 HMM_Vec3
@ctype mat4 HMM_Mat4

@vs vs
in vec3 a_pos;
in vec2 a_tex_coords;

out vec2 tex_coords;

uniform vs_params {
    mat4 model;
    mat4 view;
    mat4 projection;
};

void main() {
    gl_Position = projection * view * model * vec4(a_pos, 1.0);
    tex_coords = a_tex_coords;
}
@end

@fs fs
in vec2 tex_coords;

out vec4 frag_color;

uniform texture2D _diffuse_texture;
uniform sampler diffuse_texture_smp;
#define diffuse_texture sampler2D(_diffuse_texture, diffuse_texture_smp)

void main() {
    frag_color = texture(diffuse_texture, tex_coords);
}
@end

@vs vs_skybox
in vec3 a_pos;

out vec3 tex_coords;

uniform vs_params {
    mat4 model;
    mat4 view;
    mat4 projection;
};

void main() {
    tex_coords = a_pos;
    vec4 pos = projection * view * vec4(a_pos, 1.0);
    gl_Position = pos.xyww;
}
@end

@fs fs_skybox
in vec3 tex_coords;

out vec4 frag_color;

uniform textureCube _skybox_texture;
uniform sampler skybox_texture_smp;
#define skybox_texture samplerCube(_skybox_texture, skybox_texture_smp)

void main() {
    frag_color = texture(skybox_texture, tex_coords);
}
@end

@program simple vs fs
@program skybox vs_skybox fs_skybox
