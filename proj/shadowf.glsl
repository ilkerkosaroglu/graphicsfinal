#version 460 core

in mat4 inverseViewingMatrix;
in vec4 pos;
out vec4 fragColor;

uniform mat4 viewingMatrix;
uniform mat4 projectionMatrix;
uniform mat4 lightVM;
uniform mat4 lightPM;

uniform float wwidth;
uniform float wheight;

uniform sampler2D depth;
uniform sampler2D lightDepth;

void main(void)
{
	// vec4 pos4 = vec4(pos.xy, ;
	// vec3 dir = normalize(pos4.xyz/pos4.w);

    float bias = 0.0005;

    vec2 uv = pos.xy * 0.5 + 0.5;

    vec3 screenPos = vec3(pos.xy, texture(depth, uv).r*2-1);

    mat4 inversePV = inverse(projectionMatrix * viewingMatrix);

    vec4 worldPos = (inversePV * vec4(screenPos, 1));
    worldPos /= worldPos.w;
    // vec4 worldPos = (inverse(viewingMatrix) * inverse(projectionMatrix) * vec4(screenPos, 1));
    vec4 vp = lightVM * vec4(worldPos.xyz, 1);
    vec4 lightScreenPos = lightPM * vp;
    lightScreenPos /= lightScreenPos.w;

    // float z = 10000*(2*vp.z-(0.1 + 2000.0)) / (2000.0 - 0.1);
    vec3 lightUV = lightScreenPos.xyz * 0.5 + 0.5;
    // float currentDepth = lightScreenPos.z*10;

    // float lightDepth1 = texture(lightDepth, uv).r;
    float lightDepth1 = texture(lightDepth, lightUV.xy).r;
    // float depth = texture(depth, uv).r;
    // fragColor = vec4(lightScreenPos.w, lightScreenPos.w, lightScreenPos.w, 1.0);
    // fragColor = vec4(lightScreenPos.z, lightScreenPos.z, lightScreenPos.z, 1.0);
    // fragColor = vec4(lightScreenPos.xyz, 1.0);
    // float lightDepth2 = texture(lightDepth, lightScreenPos.xy).r;
    // fragColor = vec4(lightDepth1, lightScreenPos.z, 1.0, 1.0);
    // fragColor = vec4(lightDepth1, lightDepth1, lightDepth1, 1.0);
    // fragColor = vec4(lightDepth1, depth, 1.0, 1.0);
    // fragColor = vec4(depth, depth, depth, 1.0);

    // fragColor = vec4(lightScreenPos.xyz, 1.0);
    // fragColor = vec4(lightScreenPos.xyz, 1.0);
    // fragColor = vec4(lightScreenPos.zzz, 1.0);
    // fragColor = vec4(currentDepth.rrr, 1.0);
    // fragColor = vec4(screenPos.xyz, 1.0);
    // fragColor = vec4(vp.xy, z, 1.0);
    // fragColor = vec4(vp.zzz/2000.0, 1.0);
    // fragColor = vec4(lightUV.zzz, 1.0);
    // fragColor = vec4(lightScreenPos.zzz*1000, 1.0);
    // fragColor = vec4(lightScreenPos.z,  lightScreenPos.z, lightScreenPos.z, 1.0);
    // fragColor = vec4(depth,  depth, depth, 1.0);
    // fragColor = vec4(lightDepth1,  lightDepth1, lightDepth1, 1.0);
    // fragColor = vec4(lightDepth2,  lightDepth2, lightDepth2, 1.0);

    // without pcf
    // if(lightDepth1+ bias < lightUV.z)
    // {
    //     fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    // }
    // else
    // {
    //     fragColor = vec4(1.0, 1.0, 1.0, 1.0);
    // }

    // with pcf
    float shadow = 0.0;
    vec2 offsetMult = vec2(1.0/wwidth, 1.0/wheight) * 0.5;
    for (int x=-1; x<=1; x++){
        for (int y=-1; y<=1; y++){
            // float pcfDepth = texture(lightDepth, lightUV.xy).r;
            float pcfDepth = texture(lightDepth, lightUV.xy + vec2(x,y)*offsetMult).r;
            shadow += pcfDepth + bias < lightUV.z ? 0.0 : 1.0;
        }
    }

    shadow /= 9.0;

    fragColor = vec4(shadow, shadow, shadow, 1.0);

	// fragColor = vec4(texture(depth, uv).rrr, 1.0);
    
	// fragColor = vec4(texture(lightDepth, uv).r, texture(depth, uv).g, 1.0, 1.0);
	// fragColor = vec4(uv, 1.0, 1.0);
	// fragColor = vec4( 1.0);

}
