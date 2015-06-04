function dots_data(N)
	start_point = Point3f(0f0)
	randrange = -0.1f0:eps(Float32):0.1f0
	return (Point3f[(start_point += rand(Point3f, randrange)) for i=1:N], :dots)
end

push!(TEST_DATA, dots_data(25_000))
