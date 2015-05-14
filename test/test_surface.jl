using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, Meshes

const N = 500
function xy(x,y,i)
	x = ((x/N)-0.5f0)*i
	y = ((y/N)-0.5f0)*i
	r = sqrt(x*x + y*y)
	Float32(sin(r)/r)
end
generate(i) 		= Float32[xy(Float32(x),Float32(y),Float32(i)) for x=1:N, y=1:N]
const heightfield 	= lift(generate, bounce(1f0:200f0))
const robj 			= visualize(heightfield, :surface, color_norm=Vec2(-0.5, 1))

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()
