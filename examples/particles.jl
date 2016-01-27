using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO

w = glscreen()
cat = GLNormalMesh(loadasset("cat.obj"))
sphere = GLNormalMesh(Sphere{Float32}(Vec3f0(0), 1f0), 12)

function scale_gen(v0, nv)
	l = length(v0)
	@inbounds for i=1:l
		v0[i] = Vec3f0(1,1,sin((nv*l)/i))/2
	end
	v0
end
function color_gen(v0, nv)
	l = length(v0)
	@inbounds for x=1:l
		v0[x] = RGBA{U8}(x/l,(cos(nv)+1)/2,(sin(x/l/3)+1)/2.,1.)
	end

	v0
end
const t      = bounce(0.5f0:0.01f0:(pi*1.0f0))
ps 			 = sphere.vertices
scale_start  = Vec3f0[Vec3f0(1,1,rand()) for i=1:length(ps)]
scale_signal = foldp(scale_gen, scale_start, t)
scale 		 = scale_signal

color_signal = foldp(color_gen, zeros(RGBA{U8}, length(ps)), t)
color 		 = color_signal

rotation = -sphere.normals

a = visualize((cat, ps), scale=scale, color=color, rotation=rotation)


view(a)
view(visualize(boundingbox(a), :lines, model=a.children[][:model]), method=:perspective)

axis_points = Point3f0[
    (0,0,0), (6,0,0),
    (0,0,0), (0,6,0),
    (0,0,0), (0,0,6),
]
const C = RGBA{Float32}
axis_color = C[
    C(1,0,0,1), C(1,0,0,1),
    C(0,1,0,1), C(0,1,0,1),
    C(0,0,1,1), C(0,0,1,1),
]
view(visualize(axis_points, :linesegment, color=axis_color), method=:perspective)



GLWindow.renderloop(w)
