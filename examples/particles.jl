using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO

w,r = glscreen()
w.cameras[:perspective] = PerspectiveCamera(w.inputs, Vec3f0(3), Vec3f0(0))
cat = GLNormalMesh(loadasset("cat.obj"))
sphere = GLNormalMesh(Sphere{Float32}(Vec3f0(0), 1f0), 12)

function scale_gen(v0, nv)
	l = length(v0)
	@inbounds for i=1:l
		v0[i] = Vec3f0(1,1,sin((nv*l)/i))/2
	end
	v0
end
i = 1
function color_gen(v0, nv)
	l = length(v0)
	@inbounds for x=1:l
		v0[x] = RGBA{U8}(x/l,(cos(nv)+1)/2,(sin(x/l/3)+1)/2.,1.)
	end

	v0
end
const t      = Signal(0f0)
ps 			 = sphere.vertices
scale_start  = Vec3f0[Vec3f0(1,1,rand()) for i=1:length(ps)]
scale_signal = foldp(scale_gen, scale_start, t)
scale 		 = scale_signal

color_signal = foldp(color_gen, zeros(RGBA{U8}, length(ps)), t)
color 		 = color_signal

rotation = -sphere.normals

a = visualize((cat, ps), scale=scale, color=color, rotation=rotation)

view(a)
@async r()
yield()
sleep(5)
yield()
N = 200
i = 1
for _t in linspace(0, 2pi, N)
    yield()
    sleep(0.1)
    screenshot(w, path=joinpath(homedir(), "Videos","cats", @sprintf("frame%03d.png", i)))
    i+=1
    push!(t, _t)
end
