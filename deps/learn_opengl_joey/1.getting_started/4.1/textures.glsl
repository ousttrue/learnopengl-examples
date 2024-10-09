@vs vs
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

void main()
{
	gl_Position = vec4(aPos, 1.0);
	ourColor = aColor;
	TexCoord = vec2(aTexCoord.x, aTexCoord.y);
}
@end

@fs fs
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

uniform texture2D texture1;
uniform sampler sampler1;

void main()
{
	FragColor = texture(sampler2D(texture1, sampler1), TexCoord);
}
@end

@program textures vs fs
