#version 330

in vec2 texCoord;
in vec4 vertex_color;
in vec3 vertex_normal;
in vec3 f_vertexInView;
in vec4 V_color;

out vec4 fragColor;

// [TODO] passing texture from main.cpp
// Hint: sampler2D
uniform sampler2D tex;

uniform mat4 um4p;
uniform mat4 um4v;
uniform mat4 um4m;

uniform mat4 mvp;

uniform mat4 um4n;    // model normalization matrix
uniform mat4 um4r;    // rotation matrix

struct LightInfo{
    vec4 position;
    vec4 direction;
    vec4 La;            // Ambient light intensity
    vec4 Ld;            // Diffuse light intensity
    vec4 Ls;            // Specular light intensity
    float spotExponent;
    float spotCutoff;
    float constantAttenuation;
    float linearAttenuation;
    float quadraticAttenuation;
};

struct MaterialInfo
{
    vec4 Ka;
    vec4 Kd;
    vec4 Ks;
    float shininess;
};

uniform int lightIdx;            // Use this variable to contrl perpixel lighting mode
uniform int lightIdxv;            // Use this variable to contrl vertex lighting mode
uniform LightInfo light[3];
uniform MaterialInfo material;

vec4 directionalLight(vec3 N, vec3 V){
    // [TODO] same as fragment shader
    vec4 lightInView = um4v * light[0].position;
    vec3 S = normalize(lightInView.xyz + V);
    vec3 H = normalize(S + V);
    // [TODO] calculate diffuse coefficient and specular coefficient here
    float dc = max(dot(N, S), 0);
    float sc = pow(max(dot(N, H), 0), material.shininess);
    return light[0].La * material.Ka + dc * light[0].Ld * material.Kd + sc * light[0].Ls * material.Ks;
}

void main() {
    vec3 N = normalize(vertex_normal);
    vec3 V = -f_vertexInView;
    vec4 color = vec4(0, 0, 0, 0);
    color += directionalLight(N, V);
	// [TODO] sampleing from texture
	// Hint: texture

    vec4 texColor = vec4(texture(tex, texCoord).rgb, 3);
    
    fragColor = color;
    fragColor = texColor * color;
}
