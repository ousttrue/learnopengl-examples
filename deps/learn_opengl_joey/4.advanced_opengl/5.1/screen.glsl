@vs vs
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoords;

out vec2 TexCoords;

void main()
{
    TexCoords = aTexCoords;
    gl_Position = vec4(aPos.x, aPos.y, 0.0, 1.0); 
} 
@end

@fs fs
out vec4 FragColor;

in vec2 TexCoords;

layout(binding=0)uniform texture2D screenTexture;
layout(binding=0)uniform sampler screenTextureSampler;

void main()
{
    vec3 col = texture(sampler2D(screenTexture, screenTextureSampler), TexCoords).rgb;
    FragColor = vec4(col, 1.0);
}
@end

@program screen vs fs
