function create_isosurf(N)
	volume  = Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
	max     = maximum(volume)
	min     = minimum(volume)
	volume  = (volume .- min) ./ (max .- min)
	return GLNormalMesh(volume, 0.5f0)
end

push!(TEST_DATA, create_isosurf(64))