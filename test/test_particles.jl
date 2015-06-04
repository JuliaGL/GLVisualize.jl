generate_particles(x,i) = Point3f(
	sin(x/900)*3,
	cos(x/100)*(i/(x/100))*2, 
	cos(x/1000+(i/100))*2
)

update_particles(i, N1, N2) = Point3f[generate_particles(x*y, i) for x=1:N1,y=1:N2]
particle_color_from_signal(positions) = RGBAU8[RGBAU8(((cos(x)+1)/2),0.0,((sin(y)+1)/2),  1.0f0) for x=1:size(positions, 1), y=1:size(positions, 2)]

function particle_data(N)

	return Point3f[rand(Point3f, 0f0:eps(Float32):4f0) for x=1:N, y=1:N]
end

push!(TEST_DATA, particle_data(50))

