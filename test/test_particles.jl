using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes

const N1 = 50
const N2 = 100

generate(x,i) = Point3{Float32}(
	sin(x/500)*3,
	cos(x/50)*(i/(x/100))*2, 
	cos(x/1000+(i/100))*2
)


function update_data(i)
    positions = [generate(x, i) for x=1:N1*N2]
	reshape(positions, (N1, N2)) # needs to be 2D right now, as otherwise it can become to big for a texture very quickly. Will be automized at some point
end
color_from_pos(pos) 	= RGBAU8(((cos(pos)+1)/2)..., 1.0f0)
color_from_signal(pos) 	= map(color_from_pos, pos)

const time_i 	= bounce(1f0:50f0) # lets the values "bounce" back and forth between 1 and 50, f0 for Float32
const positions = lift(update_data, time_i)
particle_color 	= lift(color_from_signal, positions)
const robj 		= visualize(positions, model=scalematrix(Vec3(0.03f0)), particle_color=particle_color)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()
