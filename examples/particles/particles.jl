using GLVisualize, GeometryTypes, GLAbstraction
using Colors, Reactive, FileIO
if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0, 1f0, 360))
end

description = """
Showing off the flexibility of the particle system by animating
all kind of atributes for an arbitrary mesh as the particle.
"""

cat    = GLNormalMesh(loadasset("cat.obj"))
sphere = GLNormalMesh(Sphere{Float32}(Vec3f0(0), 1f0), 12)

function scale_gen(v0, nv)
    l = length(v0)
    @inbounds for i=1:l
        v0[i] = Vec3f0(1,1,sin((nv*l)/i))/2
    end
    v0
end
function color_gen(v0, t)
    l = length(v0)
    @inbounds for x=1:l
        v0[x] = RGBA{N0f8}(x/l,(cos(t)+1)/2,(sin(x/l/3)+1)/2.,1.)
    end
    v0
end

t            = const_lift(x->x+0.1, timesignal)
ps           = sphere.vertices
scale_start  = Vec3f0[Vec3f0(1,1,rand()) for i=1:length(ps)]
scale        = foldp(scale_gen, scale_start, t)
colorstart   = color_gen(zeros(RGBA{N0f8}, length(ps)), value(t))
color        = foldp(color_gen, colorstart, t)
rotation     = sphere.normals
cats = visualize((cat, ps), scale = scale, color = color, rotation = rotation)

_view(cats, window)

if !isdefined(:runtests)
    renderloop(window)
end
