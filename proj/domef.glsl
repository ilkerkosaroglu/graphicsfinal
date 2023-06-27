#version 460 core

uniform sampler2D skybox;

in vec4 fragWorldPos;
in vec3 fragWorldNor;
in vec2 fragUV;

out vec4 fragColor;

void main(void)
{

	vec3 color = texture(skybox, vec2(-fragUV.x, fragUV.y)).xyz;
	fragColor = vec4(color, 1.0);
	// vec3 col = vec3(1.0) - exp(-color * 1.0);
    // col = pow(col, vec3(1.0/2.2));
	// if(col.x > 0.8 || col.y > 0.8 || col.z > 0.8){
	// 	fragColor = vec4(color, 1.0);
	// }else{
	// 	fragColor = vec4(0,0,0, 1.0);
	// }
}
