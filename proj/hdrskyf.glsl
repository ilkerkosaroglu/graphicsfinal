#version 460 core

in mat4 inverseViewingMatrix;
in vec4 pos;
out vec4 fragColor;

uniform sampler2D skybox;

const vec2 invAtan = vec2(0.1591, 0.3183);
vec2 SampleSphericalMap(vec3 v)
{
    vec2 uv = vec2(atan(v.z, v.x), asin(v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

void main(void)
{
	vec4 pos4 = inverseViewingMatrix * pos;
	vec3 dir = normalize(pos4.xyz/pos4.w);

	// since after inverseViewingMatrix, the coordinate is left-handed
	dir.z = -dir.z;
	dir.y = -dir.y;
	vec3 color = texture(skybox, SampleSphericalMap(dir)).xyz;
	fragColor = vec4(color, 1.0);

}
