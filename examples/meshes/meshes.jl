using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

if !isdefined(:runtests)
	window = glscreen()
end

msh = GLNormalMesh(loadasset("cat.obj"))

view(visualize(msh), window)

if !isdefined(:runtests)
	renderloop(window)
end
