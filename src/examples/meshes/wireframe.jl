using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

if !isdefined(:runtests)
    window = glscreen()
end
const static_example = true

# loadasset is defined as `loadasset(name) = load(assetphat(name))`
# load comes from FileIO, which automatically detects the file format and loads it
# in general, load will try to load the mesh as is, which may return different
# meshtypes. This is why it's wrapped into GLNormalMesh, to guarantee some type
# stability.
# Formats supported are currently: obj, stl, ply, off and 2DM
msh = GLNormalMesh(loadasset("cat.obj"))
v = vertices(msh)
f = faces(msh)
colors = RGBA{Float32}[RGBA{Float32}(rand(), rand(), rand(), 0.5) for i=1:length(v)]

colored_mesh = GLNormalVertexcolorMesh(
    vertices=v, faces=f,
    color=colors
)


_view(visualize(colored_mesh, is_fully_opaque=false), window, camera=:perspective)
_view(visualize(msh, :lines, thickness=1f0), window, camera=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
