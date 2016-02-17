using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

if !isdefined(:runtests)
	window = glscreen()
end
# loadasset is defined as `loadasset(name) = load(assetphat(name))`
# load comes from FileIO, which automatically detects the file format and loads it
# in general, load will try to load the mesh as is, which may return different
# meshtypes. This is why it's wrapped into GLNormalMesh, to guarantee some type
# stability.
# Formats supported are currently: obj, stl, ply, off and 2DM
msh = GLNormalMesh(loadasset("cat.obj"))

view(visualize(msh), window)

if !isdefined(:runtests)
	renderloop(window)
end
