#version 460 core

in mat4 inverseViewingMatrix;
in vec4 pos;
out vec4 fragColor;

uniform samplerCube skybox;

const float PI = 3.14159265359;

void main(void)
{
	vec4 pos4 = inverseViewingMatrix * pos;
	vec3 dir = normalize(pos4.xyz/pos4.w);

	vec3 irradiance = vec3(0.0);  
	vec3 normal = vec3(dir.x, -dir.y, -dir.z);
	vec3 up    = vec3(0.0, 1.0, 0.0);
	vec3 right = normalize(cross(up, normal));
	up         = normalize(cross(normal, right));

	float sampleDelta = 0.01;
	// float sampleDelta = 0.005;
	// float sampleDelta = 0.001;
	float nrSamples = 0.0; 
	for(float phi = 0.0; phi < 2.0 * PI; phi += sampleDelta)
	{
		float cosPhi = cos(phi);
		float sinPhi = sin(phi);

		for(float theta = 0.0; theta < 0.5 * PI; theta += sampleDelta)
		{	
			float cosTheta = cos(theta);
			float sinTheta = sin(theta);

			// spherical to cartesian (in tangent space)
			vec3 tangentSample = vec3(sinTheta * cosPhi,  sinTheta * sinPhi, cosTheta);
			// tangent space to world
			vec3 sampleVec = tangentSample.x * right + tangentSample.y * up + tangentSample.z * normal; 

			irradiance += texture(skybox, sampleVec).rgb * cosTheta * sinTheta;

			nrSamples++;
		}
	}
	irradiance = PI * irradiance * (1.0 / float(nrSamples));

	fragColor = vec4(irradiance, 1.0);
	// fragColor = vec4(SampleSphericalMap(dir), 1.0, 1.0);
}
