if !isdefined(:runtests)
	using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO
	window = glscreen()
end

msh = GLNormalMesh(loadasset("cat.obj"))

view(visualize(msh), window)

if !isdefined(:runtests)
	renderloop(window)
end