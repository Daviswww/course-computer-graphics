#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;

out vec4 vertex_color;
out vec3 vertex_normal;
uniform mat4 mvp;

out vec3 f_vertexInView;
//void main()
//{
//    // [TODO]
//    gl_Position = mvp *  vec4(aPos.x, aPos.y, aPos.z, 1.0);
//    vertex_color = aColor;
//    vertex_normal = aNormal;
//}

uniform mat4 um4p;    // projection matrix
uniform mat4 um4v;    // camera viewing transformation matrix
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

vec4 pointLight(vec3 N, vec3 V){
    // [TODO] same as fragment shader
    vec4 lightInView = um4v * light[1].position;
    vec3 S = normalize(lightInView.xyz + V);
    vec3 H = normalize(S + V);

    float dc = max(dot(N, S), 0);
    float sc = pow(max(dot(N, H), 0), material.shininess);
   
    // attenuation
    float distance    = length(lightInView.xyz - f_vertexInView);
    float attenuation = 1.0f / (light[1].constantAttenuation + light[1].linearAttenuation * distance + light[1].quadraticAttenuation * distance * distance);

    return light[1].La * material.Ka + attenuation * (light[1].Ld  * dc * material.Kd  + light[1].Ls * sc * material.Ks);
}

vec4 spotLight(vec3 N, vec3 V){

    //[TODO] Calculate spot light intensity here
    vec4 lightInView = um4v * light[2].position;
    vec3 S = normalize(lightInView.xyz + V);
    vec3 H = normalize(S + V);

    float dc = max(dot(N, S), 0);
    float sc = pow(max(dot(N, H), 0), material.shininess);

    // attenuation
    float distance = length(lightInView.xyz + V);
    float attenuation = 1.0f / (light[1].constantAttenuation + light[1].linearAttenuation * distance + light[1].quadraticAttenuation * distance * distance);

    float cosine_value = dot(normalize(- V - lightInView.xyz), normalize(um4v * light[2].direction).xyz);
    float theta = acos(cosine_value);
    float spotFactor = pow(max(cosine_value, 0), light[2].spotExponent);
    float cutoff = light[2].spotCutoff;

    if(cutoff > theta){
        return light[2].La * material.Ka + attenuation * spotFactor * (dc * light[2].Ld * material.Kd + sc * light[2].Ls * material.Ks);
    }
    else
    {
        return light[2].La * material.Ka;
    }
}

void main() {
    
    // [TODO] transform vertex and normal into camera space
    vec4 vertexInView = um4v * um4r * um4n * vec4(aPos, 1.0);
    vec4 normalInView = transpose(inverse(um4v * um4r * um4n)) * vec4(aNormal, 0.0);

    f_vertexInView = vertexInView.xyz;
    vertex_normal = normalInView.xyz;

    vec3 N = normalize(normalInView.xyz);
    vec3 V = -vertexInView.xyz;

    if(lightIdx == 0)
    {
        vertex_color = directionalLight(N, V);
    }
    else if(lightIdx == 1)
    {
        vertex_color = pointLight(N, V);
    }
    else if(lightIdx == 2)
    {
        vertex_color = spotLight(N ,V);
    }
    
    if (material.Ka.x != 0){
        gl_Position = um4p * um4v * um4r * um4n * vec4(aPos, 1.0);
    }
}
