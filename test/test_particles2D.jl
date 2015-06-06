#using GLVisualize, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO
particle_data2D(i, N) = Point2{Float32}[rand(Point2{Float32}, -10f0:eps(Float32):10f0) for x=1:N]


push!(TEST_DATA2D, 
	(foldl(+, Point2{Float32}[rand(Point2{Float32}, 0f0:eps(Float32):1000f0) for x=1:512], 
	lift(particle_data2D, bounce(1f0:1f0:50f0), 512)), :scale=>Vec2(20)))


#view(visualize(data, scale=Vec2(20)))
#renderloop()
