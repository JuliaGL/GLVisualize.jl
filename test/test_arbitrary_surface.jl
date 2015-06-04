function arbitrary_surface_data(N)
	h = 1./N
	r = h:h:1.
	t = (-1:h:1+h)*π
	x = map(Float32, r*cos(t)')
	y = map(Float32, r*sin(t)')

	f(x,y)  = exp(-10x.^2-20y.^2)  # arbitrary function of f
	z       = Float32[Float32(f(x[k,j],y[k,j])) for k=1:size(x,1),j=1:size(x,2)]
	(x, y, z, :surface)
end
push!(TEST_DATA, arbitrary_surface_data(100))


