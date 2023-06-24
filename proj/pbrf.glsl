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
vec3 ao = vec3(0.3, 0.3, 0.3);   // ambient reflectance coefficient
vec3 kS = vec3(0.8, 0.8, 0.8);   // specular reflectance coefficient

// vec3 lightPos = vec3(5, 5, 5);   // light position in world coordinates

vec3 lightPos[4] = vec3[4](vec3(5, 5, 1), vec3(4, 5, 1), vec3(5, 4, 1), vec3(4, 4, 1));

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
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
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
}


void main(void)
{
	vec3 N = normalize(fragWorldNor);
    vec3 V = normalize(eyePos - vec3(fragWorldPos));

    vec3 F0 = vec3(0.04); 
    F0 = mix(F0, albedo, metalness);
	           
    // reflectance equation
    vec3 Lo = vec3(0.0);
    for(int i = 0; i < 4; ++i) 
    {
        // calculate per-light radiance
        vec3 L = normalize(lightPos[i] - vec3(fragWorldPos));
        vec3 H = normalize(V + L);
        float dist    = length(lightPos[i] - vec3(fragWorldPos));
        float attenuation = 1.0 / (dist * dist);
        vec3 radiance     = I * attenuation;        
        
        // cook-torrance brdf
        float NDF = DistributionGGX(N, H, roughness);        
        float G   = GeometrySmith(N, V, L, roughness);      
        vec3 F    = fresnelSchlick(max(dot(H, V), 0.0), F0);       
        
        vec3 kS = F;
        vec3 kD = vec3(1.0) - kS;
        kD *= 1.0 - metalness;	  
        
        vec3 numerator    = NDF * G * F;
        float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.0001;
        vec3 specular     = numerator / denominator;  
            
        // add to outgoing radiance Lo
        float NdotL = max(dot(N, L), 0.0);                
        Lo += (kD * albedo / PI + specular) * radiance * NdotL; 
    }   
  
    vec3 ambient = vec3(0.03) * albedo * ao;
    vec3 color = ambient + Lo;
	
    // color = color / (color + vec3(1.0));
    // color = pow(color, vec3(1.0/2.2));  
   
    fragColor = vec4(color, 1.0);
}
