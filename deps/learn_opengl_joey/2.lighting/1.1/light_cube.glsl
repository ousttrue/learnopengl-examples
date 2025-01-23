@vs vs
layout (location = 0) in vec3 aPos;

layout(binding=0)uniform vs_params {
mat4 model;
mat4 view;
mat4 projection;
};

void main()
{
	gl_Position = projection * view * model * vec4(aPos, 1.0);
}
@end

@fs fs
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0); // set all 4 vector values to 1.0
}
@end

@program light_cube vs fs
