@vs vs
layout (location = 0) in vec3 aPos;

out vec3 TexCoords;

uniform vs_params {
mat4 projection;
mat4 view;
};

void main()
{
    TexCoords = aPos;
    vec4 pos = projection * view * vec4(aPos, 1.0);
    gl_Position = pos.xyww;
} 
@end

@fs fs
out vec4 FragColor;

in vec3 TexCoords;

uniform textureCube skybox;
uniform sampler skyboxSampler;

void main()
{    
    FragColor = texture(samplerCube(skybox, skyboxSampler), TexCoords);
}
@end

@program skybox vs fs
