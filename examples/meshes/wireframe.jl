using GLVisualize, GeometryTypes, ModernGL, GLAbstraction, Colors, FileIO
if !isdefined(:runtests)
    window = glscreen()
end

description = """
Demonstrating how wireframes can be displayed.
"""



# loadasset is defined as `loadasset(name) = load(assetphat(name))`
# load comes from FileIO, which automatically detects the file format and loads it
# in general, load will try to load the mesh as is, which may return different
# meshtypes. This is why it's wrapped into GLNormalMesh, to guarantee some type
# stability.
# Formats supported are currently: obj, stl, ply, off and 2DM
msh = GLNormalMesh(loadasset("cat.obj"))
v = vertices(msh)
f = faces(msh)
colors = map(v) do _ # for each vertex
    RGBA(rand(RGB{Float32}), 0.4f0)
end

colored_mesh = GLNormalVertexcolorMesh(
    vertices = v, faces = f, color = colors
)

_view(visualize(colored_mesh), window, camera=:perspective)
_view(visualize(
    msh, :lines, thickness = 1f0,
    color = RGBA(1f0, 1f0, 1f0, 0.8f0)
), window, camera=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
