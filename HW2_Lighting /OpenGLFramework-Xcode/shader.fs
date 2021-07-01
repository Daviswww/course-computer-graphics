#version 330 core

out vec4 FragColor;
in vec4 vertex_color;
in vec3 vertex_normal;
in vec3 f_vertexInView;

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

uniform int lightIdx;            // Use this variable to contrl lighting mode
uniform mat4 um4v;                // Camera viewing transformation matrix
uniform LightInfo light[3];
uniform MaterialInfo material;
uniform int vertex_or_perpixel;

vec4 directionalLight(vec3 N, vec3 V){

    vec4 lightInView = um4v * light[0].position;
    vec3 S = normalize(lightInView.xyz + V);
    vec3 H = normalize(S + V);

    // [TODO] calculate diffuse coefficient and specular coefficient here
    float dc = max(dot(N, S), 0);
    float sc = pow(max(dot(N, H), 0), material.shininess);

    return light[0].La * material.Ka + dc * light[0].Ld * material.Kd + sc * light[0].Ls * material.Ks;
}

vec4 pointLight(vec3 N, vec3 V){
    
    // [TODO] Calculate point light intensity here
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
    float distance = length(lightInView.xyz - f_vertexInView);
    float attenuation = 1.0f / (light[1].constantAttenuation + light[1].linearAttenuation * distance + light[1].quadraticAttenuation * distance * distance);

    float cosine_value = dot(normalize(f_vertexInView - lightInView.xyz), normalize(um4v * light[2].direction).xyz);
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

    vec3 N = normalize(vertex_normal);       
    vec3 V = -f_vertexInView;
    
    vec4 color = vec4(0, 0, 0, 0);

    //[TODO] Use vertex_or_perpixel to decide which mode.
    if (vertex_or_perpixel == 1)
    {
        if(lightIdx == 0)
        {
            color += directionalLight(N, V);
        }
        else if(lightIdx == 1)
        {
            color += pointLight(N, V);
        }
        else if(lightIdx == 2)
        {
            color += spotLight(N ,V);
        }
        FragColor = color;
    }
    else
    {
        FragColor = vertex_color;
    }
}
