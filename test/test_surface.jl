using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, Meshes

const N = 500
generate(i::Float32) = Float32[sin((x/10f0)*(i/50f0))*sin((y/50f0)*(i/(x/100f0))) for x=1:N, y=1:N]
    
const heightfield 	= lift(generate, bounce(1f0:50f0))
const robj 			= visualize(heightfield, :surface, color_norm=Vec2(-1, 1))

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()
