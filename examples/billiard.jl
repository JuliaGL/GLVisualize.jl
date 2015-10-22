using BilliardModels
using GLVisualize, GeometryTypes, Reactive, ColorTypes, GLAbstraction, MeshIO, Meshes, Colors
const table 		= Sinai_billiard(0.1)
const max_particles = 8_000

function BilliardModels.step!(particles, table, _)
	for particle in particles
 		BilliardModels.step!(particle, table, 0.01)
 	end
 	particles
end
to_points(p::Particle) = Point3f0(p.x.x*2pi, p.x.y*2pi, atan2(p.v.x, p.v.y))
function to_points(data, particles)
	@inbounds for (i,p) in enumerate(particles)
		data[i] = to_points(p)
	end
	data
end

const color_ramp = map(RGBA{U8}, colormap("RdBu", 100))
function to_color(p::Particle)
	l = (atan2(p.v.x, p.v.y) + pi) / 2pi
	color_ramp[round(Int, clamp(l, 0, 1) * (length(color_ramp)-1))+1]
end
function to_color(data, particles)
	@inbounds for (i,p) in enumerate(particles)
		data[i] = to_color(p)
	end
	data
end
function test_data()
	w,r = glscreen()
	cubecamera(w)
	x0 = Vector2D(0.3, 0.1)
	particles 		= [Particle(x0, Vector2D(1.0, 0.001*i)) for i=1:max_particles]
	colors 			= texture_buffer(RGBA{U8}[RGBA{U8}(1., 0.1, clamp(0.001*i, 0.0, 1.0), 1.0) for i=1:max_particles])

	particle_stream = const_lift(BilliardModels.step!, particles, table, bounce(1:10))

	v0 				= map(to_points, particles)
	vc0 			= map(to_color, particles)
	colors 			= const_lift(to_color, vc0, particle_stream)
	pointstream 	= const_lift(to_points, v0, particle_stream)
	view(visualize(
		pointstream, :dots, color=colors, 
		#primitive=GLNormalMesh(Sphere{Float32}(Point{3, Float32}(0), 1f0)),
		point_size  = 5f0
	))
	view(visualize(
		AABB{Float32}(Vec3f0(-pi), Vec3f0(pi)), :grid
	))
	r()
end

test_data()


