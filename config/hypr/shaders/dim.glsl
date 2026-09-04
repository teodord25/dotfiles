#version 300 es

// highp, not mediump: the desktop/cinema modes drive the panel at 10-bit and
// mediump is below that precision — gradients band visibly when scaled down.
precision highp float;

in vec2 v_texcoord;

layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

const float BRIGHTNESS = 0.50;

void main() {
    vec4 color = texture(tex, v_texcoord);

    color.rgb *= BRIGHTNESS;

    fragColor = color;
}
