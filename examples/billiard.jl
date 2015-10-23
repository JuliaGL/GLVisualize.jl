Pkg.clone("https://github.com/dpsanders/BilliardModels.jl")

using BilliardModels
using GLVisualize, GeometryTypes, Reactive, ColorTypes, GLAbstraction, MeshIO, Meshes
const table 		= Sinai_billiard(0.1)
const max_particles = 8_000


function BilliardModels.step!(particles, table, _)
	for particle in particles
 		step!(particle, table, 0.01)
 	end
 	particles
end
to_points(p::Particle) = Point3{Float32}(p.x.x*2pi, p.x.y*2pi, atan2(p.v.x, p.v.y))
function to_points(data, particles)
	@inbounds for (i,p) in enumerate(particles)
		data[i] = to_points(p)
	end
	data
end
function test_data()
	x0 = Vector2D(0.3, 0.1)
	particles 		= [Particle(x0, Vector2D(1.0, 0.001*i)) for i=1:max_particles]
	colors 			= texture_buffer(RGBA{U8}[RGBA{U8}(1., 0.1, clamp(0.001*i, 0.0, 1.0), 1.0) for i=1:max_particles])

	particle_stream = lift(step!, particles, table, bounce(1:10))

	v0 				= map(to_points, particles)
	pointstream 	= lift(to_points, v0, particle_stream) 
	view(visualize(pointstream, color=colors, primitive=GLNormalMesh(Sphere(Point3{Float32}(0), 1f0))))
end

test_data()

renderloop()
