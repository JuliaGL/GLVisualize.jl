using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

N = 1024
function func(x,y)
    R = sqrt(x^2 + y^2)
    sin(R)/R
end






function send_frame(i)
	i = Float32(i)
    positions = [Point3{Float32}(sin(x/i),cos(x/i*2f0)/3f0, sin(x)*cos(x)/i) for x=1:N]
	reshape(positions, (32, 32))
end
i_counter = 0
function framefunc(_unused)
    global i_counter
    mod1(i_counter+=1, 100)
end
const time_i = lift(framefunc, fpswhen(GLVisualize.ROOT_SCREEN.inputs[:open], 20.0))

const positions = lift(send_frame, time_i)
#lift(println, positions)
const robj = visualize(positions)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()