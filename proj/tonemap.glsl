#version 460 core
out vec4 FragColor;
in vec2 pos;
uniform sampler2D scene;
uniform sampler2D shadow;
const float exposure = 1;

void main()
{
    vec2 npos = pos * 0.5 + 0.5;
    vec3 hdrColor = texture(scene, npos).rgb;
    vec3 shadowColor = texture(shadow, npos).rgb;
    // shadowColor = pow(shadowColor, vec3(2.2));
    float shadowMult = mix(shadowColor.r, 1.0, 0.5);
    hdrColor *= shadowMult;
    vec3 col = vec3(1.0) - exp(-hdrColor * exposure);
    // vec3 col = vec3(1.0) - exp(-hdrColor * exposure / shadowMult);
    col = pow(col, vec3(1.0/2.2));
    FragColor = vec4(col, 1.0);

    // vec3 L = hdrColor / (hdrColor + vec3(1.0));
    // L = pow(L, vec3(1.0/2.2));
    // FragColor = vec4(L, 1.0);

    // FragColor = vec4(hdrColor, 1.0);

    // FragColor = vec4((1-texture(scene, npos).rrr)*7, 1.0);
}