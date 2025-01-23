@vs vs
layout (location = 0) in vec3 aPos;

layout(binding=0)uniform vs_params {
mat4 projection;
mat4 view;
};

out vec3 WorldPos;

void main()
{
    WorldPos = aPos;

	mat4 rotView = mat4(mat3(view));
	vec4 clipPos = projection * rotView * vec4(WorldPos, 1.0);

	gl_Position = clipPos.xyww;
}
@end

@fs fs
out vec4 FragColor;
in vec3 WorldPos;

layout(binding=0)uniform textureCube environmentMap;
layout(binding=0)uniform sampler environmentMapSampler;

void main()
{		
    vec3 envColor = textureLod(samplerCube(environmentMap, environmentMapSampler), WorldPos, 0.0).rgb;
    
    // HDR tonemap and gamma correct
    envColor = envColor / (envColor + vec3(1.0));
    envColor = pow(envColor, vec3(1.0/2.2)); 
    
    FragColor = vec4(envColor, 1.0);
}
@end

@program background vs fs
