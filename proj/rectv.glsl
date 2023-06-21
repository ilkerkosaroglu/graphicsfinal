#version 460 core

layout(location=0) in vec3 inVertex;

out vec2 pos;
void main(void)
{

    gl_Position = vec4(inVertex.xy, 0.99, 1.0);
    pos = inVertex.xy;
}

