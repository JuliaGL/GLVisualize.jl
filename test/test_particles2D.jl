using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO
GLNormalMesh(Cube(Vec3(0), Vec3(1)))
const N1 = 100
const N2 = 300
function func(x,i)
    Point3{Float32}(	
		sin(x/500f0)*3f0,
		cos(x/50f0)*(i/(x/100f0))*2f0, 
		cos(x/1000f0+(i/100f0))*2f0
	)
end

function send_frame(i)
	i = Float32(i)
    positions = [func(x, i) for x=1:N1*N2]
	reshape(positions, (N1, N2))
end
updown = 1f0
function framefunc(v0, v1)
	global updown
    v0 > 100 && (updown = -1f0)
	v0 < 1 && (updown = 1f0)
    v0+updown
end
const time_i 	= foldl(framefunc, 1f0, fpswhen(GLVisualize.ROOT_SCREEN.inputs[:open], 60.0))
const positions = lift(send_frame, time_i)
const robj 		= visualize(positions, particle_color=RGBA(rand(Float32,3)..., 1f0), model=scalematrix(Vec3(0.03f0)))

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)


renderloop()