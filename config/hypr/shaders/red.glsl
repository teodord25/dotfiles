#version 300 es
precision mediump float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    float brightness = 0.5;
    vec4 color = texture(tex, v_texcoord);
    float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 red = vec3(luma, 0.0, 0.0);
    vec3 tinted = mix(color.rgb, red, 0.4) * brightness;
    fragColor = vec4(tinted, color.a);
}
