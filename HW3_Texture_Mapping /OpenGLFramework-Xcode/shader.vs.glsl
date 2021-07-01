#version 330

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;
layout (location = 3) in vec2 aTexCoord;

out vec2 texCoord;
out vec4 vertex_color;
out vec3 vertex_normal;
out vec3 f_vertexInView;
out vec4 V_color;

uniform mat4 um4p;
uniform mat4 um4v;
uniform mat4 um4m;

uniform mat4 mvp;

uniform mat4 um4n;    // model normalization matrix
uniform mat4 um4r;    // rotation matrix

uniform vec2 offset;
uniform int isEye;

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
// [TODO] passing uniform variable for texture coordinate offset

void main()
{
    vec4 vertexInView = um4v * um4r * um4n * vec4(aPos, 1.0);
    vec4 normalInView = transpose(inverse(um4v * um4r * um4n)) * vec4(aNormal, 0.0);
    f_vertexInView = vertexInView.xyz;
    vertex_normal = normalInView.xyz;
    vec3 N = normalize(normalInView.xyz);        // N represents normalized normal of the model in camera space
    vec3 V = -vertexInView.xyz;
    V_color = directionalLight(N, V);

	// [TODO]
    if(isEye == 1) {
        texCoord = aTexCoord + offset;
    }else{
        texCoord = aTexCoord;
    }
	

	gl_Position = um4p * um4v * um4m * vec4(aPos, 1.0);

}
