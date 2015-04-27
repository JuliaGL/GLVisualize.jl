using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

const N1 = 1000
const N2 = 300
function func(x,y)
    R = sqrt(x^2 + y^2)
    sin(R)/R
end

function send_frame(i)
	i = Float32(i)
    positions = [Point3{Float32}(sin(x),cos(x*i)/3f0, sin(x)*cos(x)/i*50) for x=1:N1*N2]
	reshape(positions, (N1, N2))
end
updown = 1
function framefunc(v0, v1)
	global updown
    v0 > 100 && (updown = -1)
	v0 < 1 && (updown = 1)
    v0+updown
end
const time_i = foldl(framefunc, 1, fpswhen(GLVisualize.ROOT_SCREEN.inputs[:open], 60.0))

const positions = lift(send_frame, time_i)
const robj 		= visualize(positions, model=scalematrix(Vec3(0.03f0)))
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()
