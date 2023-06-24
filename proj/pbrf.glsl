#version 460 core

uniform samplerCube skybox;
uniform vec3 eyePos;

uniform float metalness;
uniform float roughness;

in vec4 fragWorldPos;
in vec3 fragWorldNor;

out vec4 fragColor;

void main(void)
{
	vec3 V = normalize(eyePos - vec3(fragWorldPos));
	vec3 N = normalize(fragWorldNor);

	vec3 reflectDir = reflect(-V, N);

	// fragColor = vec4(reflectDir, 1);
	// fragColor = vec4(texture(skybox, reflectDir).xyz, 1);
	vec3 skyboxReflectDir = vec3(reflectDir.x, -reflectDir.y, -reflectDir.z);
	int i,j;
	// vec4 blurColor = vec4(0);
	// for(i=0;i<3;i++)
	// {
	// 	for(j=0;j<3;j++)
	// 	{
	// 		blurColor += texture(skybox, normalize(reflectDir + vec3(i-1, j-1, i+j) * 0.01));
	// 	}
	// }
	// blurColor /= 9.0;
	// fragColor = vec4(0,0,0,1);
	// fragColor = mccolor;
	// fragColor = mix(mccolor, blurColor, 0.3);
	vec4 mccolor = vec4(metalness, roughness, 1.0, 1.0);
	fragColor = mix(mccolor, texture(skybox, skyboxReflectDir), 0.3);
}
