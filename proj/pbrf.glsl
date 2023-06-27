#version 460 core

uniform vec3 eyePos;

uniform sampler2D brdfLUT;

uniform samplerCube irradianceMap;
uniform sampler2D albedoMap;
uniform sampler2D metalMap;
uniform sampler2D roughMap;
uniform samplerCube prefilterMap;
uniform sampler2D shadow;

uniform float metalness;
uniform float roughness;
uniform float t;
uniform int renderMode;
uniform int textureMode;
// vec3 albedo = vec3(1.0, 0, 0); // test color for diffuse
vec3 albedo = vec3(1.0, 1.0, 1.0); // test color for diffuse
// vec3 albedo = vec3(metalness, roughness, 1.0); // test color for diffuse

in vec4 fragWorldPos;
in vec3 fragWorldNor;
in vec2 uv;
in vec2 screenPos;

out vec4 fragColor;

float PI = 3.14159265359;

vec3 I = vec3(23.47, 21.31, 20.79);          // point light intensity
vec3 Iamb = vec3(0.8, 0.8, 0.8); // ambient light intensity
vec3 kD = vec3(1, 0.2, 0.2);     // diffuse reflectance coefficient
vec3 ka = vec3(0.5, 0.5, 0.5);   // ambient reflectance coefficient
vec3 kS = vec3(0.8, 0.8, 0.8);   // specular reflectance coefficient

// vec3 lightPos = vec3(5, 5, 5);   // light position in world coordinates

vec3 lightPos[4] = vec3[4](vec3(7.5, 3.0, 7.5), vec3(4.5, 3.0, 7.5), vec3(7.5, 3.0, 4.5), vec3(4.5, 3.0, 4.5));

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
} 
vec3 fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness)
{
    return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float DistributionGGX(float NdotH, float roughness)
{
    float a      = roughness*roughness;
    float a2     = a*a;

    float NdotH2 = NdotH*NdotH;
	
    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
	
    return num / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return num / denom;
}
float GeometrySmith(float NdotL, float NdotV, float roughness)
{
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);	
    return ggx1 * ggx2;
}

vec3 getAlbedo(){
	if(textureMode == 1){
		return texture(albedoMap, uv).rgb;
	}
	return albedo;
}

float getMetalness(){
	if(textureMode == 1){
		return texture(metalMap, uv).r;
	}
	return metalness;
}

float getRoughness(){
	if(textureMode == 1){
		return texture(roughMap, uv).r;
	}
	return roughness;
}

vec3 calcLight(vec3 lightPos){
	vec3 lw = lightPos - vec3(fragWorldPos);
	float dist = length(lw);
	vec3 L = lw/dist;

	vec3 V = normalize(eyePos - vec3(fragWorldPos));
	vec3 H = normalize(L + V);
	vec3 N = normalize(fragWorldNor);

	float NdotL = max(dot(N, L), 0.0);  // for diffuse component
	float HdotV = max(dot(H, V), 0.0); // for specular component
	float NdotH = max(dot(H, N), 0.0); // for specular component
	float NdotV = max(dot(N, V), 0.0);

	float att = 1.0 / (dist*dist);
	// att = 1.0;

	vec3 radiance     = I * att;

	vec3 albedo = getAlbedo();
	float metalness = getMetalness();
	float roughness = getRoughness();

	vec3 F0 = vec3(0.04);
	F0      = mix(F0, albedo, metalness);
	vec3 F  = fresnelSchlick(HdotV, F0);

	kS = F;
	kD = 1.0 - kS;
	kD *= 1.0 - metalness;

	float NDF = DistributionGGX(NdotH, roughness);       
	float G   = GeometrySmith(NdotL, NdotV, roughness); 

	// vec3 numerator    = F;
	vec3 numerator    = NDF * G * F;
	float denominator = 4.0 * NdotV * NdotL  + 0.0001;
	vec3 specular     = numerator / denominator;

	
	// return F;
	// return vec3(0,0,0);
	return (kD * albedo / PI + specular) * radiance * NdotL;
}

vec3 sampleFromCubeMap(samplerCube cubeMap, vec3 dir){
	vec3 newDir = vec3(dir.x, -dir.y, -dir.z);
	return texture(cubeMap, newDir).rgb;
}

void main(void)
{
	// I *= 10;
	vec3 final = vec3(0, 0, 0);

	// for(int i = 0; i < 4; i++){
	// 	final += calcLight(lightPos[i]);
	// }

	vec3 V = normalize(eyePos - vec3(fragWorldPos));
	vec3 N = normalize(fragWorldNor);
	float NdotV = max(dot(N, V), 0.0);

	vec3 albedo = getAlbedo();
	vec3 F0 = vec3(0.04);
	float metalness = getMetalness();
	float roughness = getRoughness();
	F0      = mix(F0, albedo, metalness);

	vec3 kS = fresnelSchlickRoughness(NdotV, F0, roughness); 
	vec3 kD = 1.0 - kS;
	kD *= 1.0 - metalness;

	vec3 irradiance = sampleFromCubeMap(irradianceMap, N).rgb;
	vec3 diffuse    = irradiance * albedo;
	
	vec3 reflectDir = reflect(-V, N);
	vec3 skyboxReflectDir = vec3(reflectDir.x, -reflectDir.y, -reflectDir.z);

	vec3 prefilteredColor = textureLod(prefilterMap, skyboxReflectDir,  roughness * 4).rgb;   
	vec2 envBRDF  = texture(brdfLUT, vec2(NdotV, roughness)).rg;
	vec3 specular = prefilteredColor * (kS * envBRDF.x + envBRDF.y);

	float shadowMult = mix(texture(shadow, screenPos).r, 1.0, 0.6);
	// float shadowMult = texture(shadow, screenPos).r;

	vec3 oldambient    = (kD * diffuse) * ka;
	vec3 ambient    = (kD * diffuse + specular * shadowMult * shadowMult) * ka;
	final+= ambient;
	
	// final = vec3(shadowMult);


	

	vec3 N2 =vec3(N.x, -N.y, -N.z);

	// fragColor = vec4(uv, 0, 1);
	// fragColor = vec4(getAlbedo(), 1);

	fragColor = vec4(final, 1);
	
	if(renderMode == 1){
		fragColor = vec4(textureLod(prefilterMap, N2, (sin(t/60.0)/2+0.5)*4.0).rgb,1.0);
	}
	if(renderMode == 2){
		fragColor = vec4(sampleFromCubeMap(irradianceMap, N).rgb, 1);
	}
	if(renderMode == 3){
		fragColor = vec4(oldambient, 1);
	}
	if(renderMode == 4){
		fragColor = vec4(0,0,0, 1);
		for(int i = 0; i < 4; i++){
			fragColor += vec4(calcLight(lightPos[i]),1);
		}
	}
	if(renderMode == 5){
		for(int i = 0; i < 4; i++){
			fragColor += vec4(calcLight(lightPos[i]),1);
		}
	}
	// fragColor = vec4(texture(brdfLUT, uv).rgb, 1);
	// fragColor = vec4(sampleFromCubeMap(prefilterMap, N), 1);
	// fragColor = vec4(getMetalness(), getRoughness(),0, 1);
	// fragColor = vec4(getMetalness(), 1.0,1.0, 1);
	// fragColor = vec4(getRoughness(), 1.0,1.0, 1);
	// fragColor = vec4(NdotL, NdotH, NdotV, 1);
	// fragColor = vec4(F, 1);
	// fragColor = mix(vec4(final, 1), texture(skybox, skyboxReflectDir), 0.3);
	// fragColor = texture(skybox, skyboxReflectDir);
	// fragColor = texture(shadow, uv);
}
