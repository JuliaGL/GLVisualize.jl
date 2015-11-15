using GLAbstraction, GLVisualize, ModernGL, GeometryTypes, Reactive

linevert = vert"
{{GLSL_VERSION}}

in vec3 vertex;

uniform mat4 projectionview;

void main(){
   	gl_Position = projectionview * vec4(vertex, 1.0);
}
"
linefrag = frag"
{{GLSL_VERSION}}

out vec4 frag_color;
void main(){
   	frag_color = vec4(1,0,0,1);
}
"
lineshader = TemplateProgram(linevert, linefrag)

N  = 5
PD = 4
verts 	= Point3{Float32}[Point3{Float32}(sin(i), cos(i), cos(i)) for i=1:N*PD] #  Vec3 == Vector3{Float32} GLSL alike alias for immutable array
indexes = vcat([GLuint[0,1,1,2,2,3,3,0] + i for i=0:(N-1)]...)

lines = std_renderobject(Dict(
			:vertex           => GLBuffer(verts), #NOT WORKING
			:index            => indexbuffer(indexes), #NOT WORKING
			:projectionview   => GLVisualize.ROOT_SCREEN.perspectivecam.projectionview
		), Signal(lineshader), Signal(AABB{Float32}(verts)), GL_LINES) #Signal(AABB(verts)) -> calculates boundingbox

push!(GLVisualize.ROOT_SCREEN.renderlist, lines)

renderloop()