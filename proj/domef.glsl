#version 460 core

uniform sampler2D skybox;

in vec4 fragWorldPos;
in vec3 fragWorldNor;
in vec2 fragUV;

out vec4 fragColor;

void main(void)
{

	fragColor = vec4(texture(skybox, fragUV).xyz, 1.0);
}
