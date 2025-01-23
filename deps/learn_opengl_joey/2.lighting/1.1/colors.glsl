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
  
layout(binding=1)uniform fs_params {
  vec3 objectColor;
  vec3 lightColor;
};

void main()
{
    FragColor = vec4(lightColor.xyz * objectColor.xyz, 1.0);
}
@end

@program colors vs fs
