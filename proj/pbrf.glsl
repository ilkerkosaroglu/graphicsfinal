#version 460 core

uniform samplerCube skybox;
uniform vec3 eyePos;

uniform float metalness;
uniform float roughness;
// vec3 albedo = vec3(1.0, 0, 0); // test color for diffuse
vec3 albedo = vec3(1.0, 1.0, 1.0); // test color for diffuse
// vec3 albedo = vec3(metalness, roughness, 1.0); // test color for diffuse

in vec4 fragWorldPos;
in vec3 fragWorldNor;

out vec4 fragColor;

float PI = 3.14159265359;

vec3 I = vec3(23.47, 21.31, 20.79);          // point light intensity
vec3 Iamb = vec3(0.8, 0.8, 0.8); // ambient light intensity
vec3 kD = vec3(1, 0.2, 0.2);     // diffuse reflectance coefficient
vec3 ka = vec3(0.3, 0.3, 0.3);   // ambient reflectance coefficient
vec3 kS = vec3(0.8, 0.8, 0.8);   // specular reflectance coefficient

// vec3 lightPos = vec3(5, 5, 5);   // light position in world coordinates

vec3 lightPos[4] = vec3[4](vec3(5, 5, 1), vec3(4, 5, 1), vec3(5, 4, 1), vec3(4, 4, 1));

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
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

	vec3 F0 = vec3(0.04);
	F0      = mix(F0, albedo, metalness);
	vec3 F  = fresnelSchlick(HdotV, F0);

	kS = F;
	kD = 1.0 - kS;
	kD *= 1.0 - metalness;

	float NDF = DistributionGGX(NdotH, roughness);       
	float G   = GeometrySmith(NdotL, NdotV, roughness); 

	vec3 numerator    = NDF * G * F;
	float denominator = 4.0 * NdotV * NdotL  + 0.0001;
	vec3 specular     = numerator / denominator;

	
	// return F;
	// return vec3(0,0,0);
	return (kD * albedo / PI + specular) * radiance * NdotL;
}

void main(void)
{
	// I *= 10;
	vec3 final = vec3(0, 0, 0);

	// float att = 1.0 / (1.0 + 0.1 * dist + 0.01 * dist * dist);

	
	vec3 V = normalize(eyePos - vec3(fragWorldPos));
	vec3 N = normalize(fragWorldNor);

	for(int i = 0; i < 4; i++){
		final += calcLight(lightPos[i]);
	}

	// vec3 lw = lightPos[0] - vec3(fragWorldPos);
	// float dist = length(lw);
	// vec3 L = lw/dist;

	// vec3 V = normalize(eyePos - vec3(fragWorldPos));
	// vec3 H = normalize(L + V);
	// vec3 N = normalize(fragWorldNor);

	// float NdotL = max(dot(N, L), 0.0);  // for diffuse component
	// float HdotV = max(dot(H, V), 0.0); // for specular component
	// float NdotH = max(dot(N, H), 0.0); // for specular component
	// float NdotV = max(dot(N, V), 0.0);

	// float att = 1.0 / (dist*dist);
	// // att = 1.0;

	// vec3 radiance     = I * att;

	// F0      = mix(F0, albedo, metalness);
	// vec3 F  = fresnelSchlick(NdotH, F0);

	// kS = F;
	// kD = 1.0 - kS;
	// kD *= 1.0 - metalness;

	// float NDF = DistributionGGX(NdotH, roughness);       
	// float G   = GeometrySmith(NdotL, NdotV, roughness); 

	// vec3 numerator    = NDF * G * F;
	// float denominator = 4.0 * NdotV * NdotL  + 0.0001;
	// vec3 specular     = numerator / denominator;

	// final = (kD * albedo / PI + specular) * radiance * NdotL;

	vec3 ambient = vec3(0.1) * albedo * ka;
	final+= ambient;
	
	vec3 reflectDir = reflect(-V, N);

	vec3 skyboxReflectDir = vec3(reflectDir.x, -reflectDir.y, -reflectDir.z);

	// fragColor = vec4(2,2,2, 1);
	fragColor = vec4(final, 1);
	// fragColor = vec4(NdotL, NdotH, NdotV, 1);
	// fragColor = vec4(F, 1);
	// fragColor = mix(vec4(final, 1), texture(skybox, skyboxReflectDir), 0.3);
}
