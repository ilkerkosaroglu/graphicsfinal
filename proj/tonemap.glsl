#version 460 core
out vec4 FragColor;
in vec2 pos;
uniform sampler2D scene;
const float exposure = 1.0;

void main()
{
    vec2 npos = pos * 0.5 + 0.5;
    vec3 hdrColor = texture(scene, npos).rgb;
    vec3 mapped = vec3(1.0) - exp(-hdrColor * exposure);
    // npos = vec2(pow(npos.x, 0.01),pow(npos.y, 0.01));
    FragColor = vec4(mapped, 1.0);
}