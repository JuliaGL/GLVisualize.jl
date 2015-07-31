using GLVisualize, NPZ, GeometryTypes, GLAbstraction

function create_particles()
	volume 	  = npzread("mri.npz")["data"]
	positions = Point3{Float32}[]
	dims 	  = Point3{Float32}(size(volume)...)
	for x=1:size(volume, 1), y=1:size(volume, 2), z=1:size(volume, 3)
		intensity = volume[x,y,z] / 256.0
		intensity > 0.1 && intensity < 0.2 && push!(positions, Point3{Float32}(x,y,z)./dims)
	end
	positions
end

view(visualize(create_particles(), scale=Vec3(0.001)))

renderloop()