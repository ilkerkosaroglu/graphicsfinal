#version 460 core

in vec4 fragWorldPos;
in vec3 fragWorldNor;
in vec2 fragUV;

out vec4 fragColor;

void main(void)
{

	fragColor = vec4(normalize(fragWorldNor), 1.0);

}
