using GLVisualize, AbstractGPUArray, GLAbstraction, MeshIO, GeometryTypes, Reactive

const N = 128
function send_frame(i)
    Float32[sin((x/10f0)*(i/50f0))*sin((y/50f0)*(i/(x/100f0))) for x=1:N, y=1:N]
end
updown = 1f0
function framefunc(v0, v1)
	global updown
    v0 > 100f0 && (updown = -1f0)
	v0 < 1f0 && (updown = 1f0)
    v0+updown
end

const time_i 		= foldl(framefunc, 1f0, fpswhen(GLVisualize.ROOT_SCREEN.inputs[:open], 60.0))
const heightfield 	= lift(send_frame, time_i)
const robj 			= visualize(heightfield, :surface, color_norm=Vec2(-1, 1))
const robj1 		= visualize([sin(x/20f0)*sin(x/10f0)/2f0+sin(y/20f0) for x=1:N, y=1:N], :surface, model=Input(translationmatrix(Vec3(2,0,0))))

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)


renderloop()
