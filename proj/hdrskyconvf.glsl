#version 460 core

in mat4 inverseViewingMatrix;
in vec4 pos;
out vec4 fragColor;

uniform sampler2D skybox;

const float PI = 3.14159265359;

const vec2 invAtan = vec2(0.1591, 0.3183);
vec2 SampleSphericalMap(vec3 v)
{
    vec2 uv = vec2(atan(v.z, v.x), asin(v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

// const float m = 100.0;
// const float d = 1.0;

void main(void)
{
	vec4 pos4 = inverseViewingMatrix * pos;
	vec3 dir = normalize(pos4.xyz/pos4.w);
	vec3 lambda = vec3(1.0, 1.0, 1.0);

	vec3 irradiance = vec3(0.0);  
	vec3 normal = dir;
	vec3 up    = vec3(0.0, 1.0, 0.0);
	vec3 right = normalize(cross(up, normal));
	up         = normalize(cross(normal, right));

	vec2 texCoord = SampleSphericalMap(dir);

	// float sampleDelta = 0.1;
	float sampleDelta = 0.005;
	float nrSamples = 0.0; 
	for(float phi = 0.0; phi < 2.0 * PI; phi += sampleDelta)
	{
		float u = phi / (2.0 * PI);

		for(float theta = 0.0; theta < 0.5 * PI; theta += sampleDelta)
		{	
			// spherical to cartesian (in tangent space)
			vec3 tangentSample = vec3(sin(theta) * cos(phi),  sin(theta) * sin(phi), cos(theta));
			// tangent space to world
			vec3 sampleVec = tangentSample.x * right + tangentSample.y * up + tangentSample.z * normal; 

			irradiance += texture(skybox, SampleSphericalMap(sampleVec)).rgb * cos(theta) * sin(theta);
			// float v = theta / PI;

			// irradiance += texture(skybox, vec2(u,v) + texCoord).rgb * cos(theta) * sin(theta);
			nrSamples++;
		}
	}
	irradiance = PI * irradiance * (1.0 / float(nrSamples));

	fragColor = vec4(irradiance, 1.0);
}
