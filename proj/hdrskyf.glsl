#version 460 core

in mat4 inverseViewingMatrix;
in vec4 pos;
out vec4 fragColor;

uniform sampler2D skybox;
uniform float skyd;
uniform float skym;

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

	float m = skym;
	float d = skyd;

	// if(dir.y < 0){
	// 	vec3 hit = (d / dir.y) * dir;
	// 	vec2 u = hit.xz;
	// 	if(length(u) < m){
	// 		float deep = sqrt(m*m - dot(u, u));
	// 		hit.y = -deep-d;
	// 		lambda = normalize(hit);
	// 		vec3 color = texture(skybox, SampleSphericalMap(lambda)).xyz;
	// 		fragColor = vec4(color, 1.0);
	// 		return;
	// 	}
	// }
	vec3 color = texture(skybox, SampleSphericalMap(dir)).xyz;
	fragColor = vec4(clamp(color, 0.0, 10000.0), 1.0);
	// fragColor = vec4(clamp(color, 0.0, 10000000.0), 1.0);

}
