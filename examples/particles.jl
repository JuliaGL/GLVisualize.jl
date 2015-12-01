using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO

w,r = glscreen()
cat = GLNormalMesh(loadasset("cat.obj"))
sphere = GLNormalMesh(Sphere{Float32}(Vec3f0(0), 1f0), 32)

function scale_gen(v0, nv)
	l = length(v0)
	@inbounds for i=1:l
		v0[i] = Vec3f0(1,1,sin((nv*l)/i))/7f0
	end
	v0
end
function color_gen(v0, nv)
	l = length(v0)
	@inbounds for x=1:l
		v0[x] = RGBA{U8}(x/l,nv,(sin(x/l/3)+1)/2.,1.)
	end
	v0
end
ps 			 = sphere.vertices
scale_start  = Vec3f0[Vec3f0(1,1,rand()) for i=1:length(ps)]
scale_signal = foldp(scale_gen, scale_start, bounce(0.1f0:0.01f0:1.0f0))
scale 		 = scale_signal

color_signal = foldp(color_gen, zeros(RGBA{U8}, length(ps)), bounce(0.00f0:0.02f0:1.0f0))
color 		 = color_signal

rotation = -sphere.normals

a = visualize((cat, ps), scale=scale, color=color, rotation=rotation)

cat_verts = vertices(cat)


cat_verts_signal = foldp(copy(cat_verts), bounce(0.00f0:0.1f0:1.0f0)) do v0, ts
    l = length(cat_verts)
    @inbounds for i=1:l
        catx,caty,catz = cat_verts[i]
        x = sin(ts*catx)
        y = cos(ts*caty)
        v0[i] = cat_verts[i] + Point3f0(x,y,0)
    end
    v0
end
b = visualize((GLNormalMesh(centered(Sphere)), cat_verts_signal), scale=Vec3f0(0.01))
view(visualize([a,b], gap=Vec3f0(0)))
r()
