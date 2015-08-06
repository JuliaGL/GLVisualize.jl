using GLVisualize, NPZ, GeometryTypes, GLAbstraction, GLWindow
screen, renderloop = Screen()
#=
function create_particles()
	volume 	  = npzread("mri.npz")["data"]
	positions = Point{3, Float32}[]
	dims 	  = Point{3, Float32}(size(volume)...)
	for x=1:size(volume, 1), y=1:size(volume, 2), z=1:size(volume, 3)
		intensity = volume[x,y,z] / 256.0
		intensity > 0.1 && intensity < 0.2 && push!(positions, Point{3, Float32}(x,y,z)./dims)
	end
	positions
end
view(visualize(create_particles(), scale=Vec3f0(0.001)))
=#
view(visualize(rand(Float32, 71,73)))
renderloop()