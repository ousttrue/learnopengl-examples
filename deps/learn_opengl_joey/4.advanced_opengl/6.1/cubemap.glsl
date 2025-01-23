@vs vs
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoords;

out vec2 TexCoords;

layout(binding=0)uniform vs_params {
mat4 model;
mat4 view;
mat4 projection;
};

void main()
{
    TexCoords = aTexCoords;
    gl_Position = projection * view * model * vec4(aPos, 1.0);
}
@end

@fs fs
out vec4 FragColor;

in vec2 TexCoords;

layout(binding=0)uniform texture2D texture1;
layout(binding=0)uniform sampler texture1Sampler;

void main()
{    
    FragColor = texture(sampler2D(texture1, texture1Sampler), TexCoords);
}
@end

@program cubemap vs fs
