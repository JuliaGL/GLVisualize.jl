attribute vec2 position;
attribute vec2 normal;
attribute float miter;
uniform mat4 projection;

void main() {
    //push the point along its normal by half thickness
    vec2 p = position.xy + vec2(normal * thickness/2.0 * miter);
    gl_Position = projection * vec4(p, 0.0, 1.0);
}