generate_particles(N,x,i) = Point3f(
	sin(i+x/20f0),
	cos(i+x/20f0), 
	(2x/N)+i/10f0
)
update_particles(i, N) 		 = Point3f[generate_particles(N,x, i) for x=1:N]
particle_color(i, positions) = RGBAU8[RGBAU8(((cos(pos.x)+1)/2),i/10f0,((sin(pos.y)+1)/2),  1.0f0) for pos in positions]

function particle_data(N)
	t 			=  bounce(1f0:0.1f0:10f0)
	locations 	= lift(update_particles, t, N)
	colors 		= lift(particle_color, t, locations)
	(locations, :color=>colors)
	#visualize(locations, color=colors)
end
particle_color_pulse(x) = RGBA(x, 0f0, 1f0-x, 1f0)

push!(TEST_DATA, particle_data(1024))
push!(TEST_DATA,  (
	Point3f[rand(Point3f, 0f0:0.001f0:2f0) for i=1:1024], 
	:primitive 	=> GLNormalMesh(file"cat.obj"), 
	:color 		=> lift(particle_color_pulse, bounce(0f0:0.1f0:1f0)), 
	:scale 		=> Vec3(0.2)
))

#=
using Reactive, GLVisualize, GLAbstraction, GeometryTypes, ColorTypes, FileIO, MeshIO, Meshes, WavefrontObj
typealias Point3f Point3{Float32}
view(particle_data(1024))
view(visualize(
	Point3f[rand(Point3f, 0f0:0.001f0:2f0) for i=1:1024], 
	primitive 	= GLNormalMesh(file"cat.obj"), 
	color 		= lift(particle_color_pulse, bounce(0f0:0.1f0:1f0)), 
	scale 		= Vec3(0.2))
)
renderloop()
=#
