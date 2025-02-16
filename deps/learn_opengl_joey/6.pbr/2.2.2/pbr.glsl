@vs vs
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTexCoords;

out vec2 TexCoords;
out vec3 WorldPos;
out vec3 Normal;

layout(binding=0)uniform vs_params {
  mat4 projection;
  mat4 view;
  mat4 model;
  vec3 normalMatrixCol0;
  vec3 normalMatrixCol1;
  vec3 normalMatrixCol2;
};

void main() {
  TexCoords = aTexCoords;
  WorldPos = vec3(model * vec4(aPos, 1.0));
  mat3 normalMatrix = mat3(normalMatrixCol0, normalMatrixCol1, normalMatrixCol2);
  Normal = normalMatrix * aNormal;

  gl_Position = projection * view * vec4(WorldPos, 1.0);
}
@end

@fs fs 
out vec4 FragColor;
in vec2 TexCoords;
in vec3 WorldPos;
in vec3 Normal;

// material parameters
layout(binding=0)uniform texture2D albedoMap;
layout(binding=1)uniform texture2D normalMap;
layout(binding=2)uniform texture2D metallicMap;
layout(binding=3)uniform texture2D roughnessMap;
layout(binding=4)uniform texture2D aoMap;
layout(binding=0)uniform sampler albedoMapSampler;
layout(binding=1)uniform sampler normalMapSampler;
layout(binding=2)uniform sampler metallicMapSampler;
layout(binding=3)uniform sampler roughnessMapSampler;
layout(binding=4)uniform sampler aoMapSampler;


// IBL
layout(binding=5)uniform textureCube irradianceMap;
layout(binding=6)uniform textureCube prefilterMap;
layout(binding=7)uniform texture2D brdfLUT;
layout(binding=5)uniform sampler irradianceMapSampler;
layout(binding=6)uniform sampler prefilterMapSampler;
layout(binding=7)uniform sampler brdfLUTSampler;

layout(binding=1)uniform fs_params {
  // lights
  vec4 lightPositions[4];
  vec4 lightColors[4];

  vec3 camPos;
};

const float PI = 3.14159265359;
// ----------------------------------------------------------------------------
// Easy trick to get tangent-normals to world-space to keep PBR code simplified.
// Don't worry if you don't get what's going on; you generally want to do normal
// mapping the usual way for performance anyways; I do plan make a note of this
// technique somewhere later in the normal mapping tutorial.
vec3 getNormalFromMap() {
  vec3 tangentNormal = texture(
        sampler2D(normalMap, normalMapSampler), TexCoords
      ).xyz * 2.0 - 1.0;

  vec3 Q1 = dFdx(WorldPos);
  vec3 Q2 = dFdy(WorldPos);
  vec2 st1 = dFdx(TexCoords);
  vec2 st2 = dFdy(TexCoords);

  vec3 N = normalize(Normal);
  vec3 T = normalize(Q1 * st2.t - Q2 * st1.t);
  vec3 B = -normalize(cross(N, T));
  mat3 TBN = mat3(T, B, N);

  return normalize(TBN * tangentNormal);
}
// ----------------------------------------------------------------------------
float DistributionGGX(vec3 N, vec3 H, float roughness) {
  float a = roughness * roughness;
  float a2 = a * a;
  float NdotH = max(dot(N, H), 0.0);
  float NdotH2 = NdotH * NdotH;

  float nom = a2;
  float denom = (NdotH2 * (a2 - 1.0) + 1.0);
  denom = PI * denom * denom;

  return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySchlickGGX(float NdotV, float roughness) {
  float r = (roughness + 1.0);
  float k = (r * r) / 8.0;

  float nom = NdotV;
  float denom = NdotV * (1.0 - k) + k;

  return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
  float NdotV = max(dot(N, V), 0.0);
  float NdotL = max(dot(N, L), 0.0);
  float ggx2 = GeometrySchlickGGX(NdotV, roughness);
  float ggx1 = GeometrySchlickGGX(NdotL, roughness);

  return ggx1 * ggx2;
}
// ----------------------------------------------------------------------------
vec3 fresnelSchlick(float cosTheta, vec3 F0) {
  return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}
// ----------------------------------------------------------------------------
vec3 fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness) {
  return F0 + (max(vec3(1.0 - roughness), F0) - F0) *
                  pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}
// ----------------------------------------------------------------------------
void main() {
  // material properties
  vec3 albedo = pow(texture(
        sampler2D(albedoMap, albedoMapSampler), TexCoords
      ).rgb, vec3(2.2));
  float metallic = texture(
        sampler2D(metallicMap, metallicMapSampler), TexCoords
      ).r;
  float roughness = texture(
        sampler2D(roughnessMap, roughnessMapSampler), TexCoords
      ).r;
  float ao = texture(
        sampler2D(aoMap, aoMapSampler), TexCoords
      ).r;

  // input lighting data
  vec3 N = getNormalFromMap();
  vec3 V = normalize(camPos - WorldPos);
  vec3 R = reflect(-V, N);

  // calculate reflectance at normal incidence; if dia-electric (like plastic)
  // use F0 of 0.04 and if it's a metal, use the albedo color as F0 (metallic
  // workflow)
  vec3 F0 = vec3(0.04);
  F0 = mix(F0, albedo, metallic);

  // reflectance equation
  vec3 Lo = vec3(0.0);
  for (int i = 0; i < 4; ++i) {
    // calculate per-light radiance
    vec3 L = normalize(lightPositions[i].xyz - WorldPos);
    vec3 H = normalize(V + L);
    float distance = length(lightPositions[i].xyz - WorldPos);
    float attenuation = 1.0 / (distance * distance);
    vec3 radiance = lightColors[i].xyz * attenuation;

    // Cook-Torrance BRDF
    float NDF = DistributionGGX(N, H, roughness);
    float G = GeometrySmith(N, V, L, roughness);
    vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);

    vec3 numerator = NDF * G * F;
    float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) +
                        0.0001; // + 0.0001 to prevent divide by zero
    vec3 specular = numerator / denominator;

    // kS is equal to Fresnel
    vec3 kS = F;
    // for energy conservation, the diffuse and specular light can't
    // be above 1.0 (unless the surface emits light); to preserve this
    // relationship the diffuse component (kD) should equal 1.0 - kS.
    vec3 kD = vec3(1.0) - kS;
    // multiply kD by the inverse metalness such that only non-metals
    // have diffuse lighting, or a linear blend if partly metal (pure metals
    // have no diffuse light).
    kD *= 1.0 - metallic;

    // scale light by NdotL
    float NdotL = max(dot(N, L), 0.0);

    // add to outgoing radiance Lo
    Lo += (kD * albedo / PI + specular) * radiance *
          NdotL; // note that we already multiplied the BRDF by the Fresnel (kS)
                 // so we won't multiply by kS again
  }

  // ambient lighting (we now use IBL as the ambient term)
  vec3 F = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, roughness);

  vec3 kS = F;
  vec3 kD = 1.0 - kS;
  kD *= 1.0 - metallic;

  vec3 irradiance = texture(
        samplerCube(irradianceMap, irradianceMapSampler), N
      ).rgb;
  vec3 diffuse = irradiance * albedo;

  // sample both the pre-filter map and the BRDF lut and combine them together
  // as per the Split-Sum approximation to get the IBL specular part.
  const float MAX_REFLECTION_LOD = 4.0;
  vec3 prefilteredColor =
      textureLod(
        samplerCube(prefilterMap, prefilterMapSampler), R, roughness * MAX_REFLECTION_LOD
      ).rgb;
  vec2 brdf = texture(
        sampler2D(brdfLUT, brdfLUTSampler), vec2(max(dot(N, V), 0.0), roughness)
      ).rg;
  vec3 specular = prefilteredColor * (F * brdf.x + brdf.y);

  vec3 ambient = (kD * diffuse + specular) * ao;

  vec3 color = ambient + Lo;

  // HDR tonemapping
  color = color / (color + vec3(1.0));
  // gamma correct
  color = pow(color, vec3(1.0 / 2.2));

  FragColor = vec4(color, 1.0);
}
@end

@program pbr vs fs
