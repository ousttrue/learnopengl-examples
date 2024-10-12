@vs vs
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoords;

out vec2 TexCoords;

void main()
{
    TexCoords = aTexCoords;
	gl_Position = vec4(aPos, 1.0);
}
@end

@fs fs
out vec4 FragColor;
in vec2 TexCoords;

uniform texture2D texture1;
uniform sampler texture1Sampler;

void main()
{		
    FragColor = texture(sampler2D(texture1, texture1Sampler), TexCoords);
}
@end

@program quad vs fs
