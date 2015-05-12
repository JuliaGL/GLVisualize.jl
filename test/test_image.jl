using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, FileIO, ImageIO, ModernGL

function play{T}(array::Array{T, 3}, slice)
	array[:, :, slice]
end

img 	= read(file"test.gif")
giff 	= lift(play, img.data, bounce(1:size(img, 3)))
robj1 	= visualize(giff)

robj2 	= visualize(file"drawing.jpg", model=translationmatrix(Vec3(0,1000,0)))
robj3 	= visualize(RGBA{Float32}[rgba(sin(i), sin(j), cos(i), sin(j)*cos(i)) for i=1:0.1:12, j=1:0.1:12], model=translationmatrix(Vec3(1000,0,0)))

push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj2)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj3)
glClearColor(1f0,1f0,1f0,1f0)

renderloop()