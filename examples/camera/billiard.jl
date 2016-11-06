#=
For this example you need to checkout this package:
Pkg.clone("https://github.com/dpsanders/BilliardModels.jl")
Pkg.checkout("BilliardModels", "time_step")
=#
using GLAbstraction, MeshIO, Colors
using GLVisualize, GeometryTypes, Reactive, ColorTypes
if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end
const interactive_example = true

using BilliardModels

# create the billiard table
const table = Sinai_billiard(0.1)
const max_particles = 8_000

# function that steps through the simulation
function BilliardModels.step!(particles, table, _)
    for particle in particles
         BilliardModels.step!(particle, table, 0.01)
     end
     particles
end

# convert a particle to a point
function to_points(data, particles)
    @inbounds for (i,p) in enumerate(particles)
        data[i] = to_points(p)
    end
    data
end
to_points(p::BilliardModels.Particle) = Point3f0(p.x.x*2pi, p.x.y*2pi, atan2(p.v.x, p.v.y))

# color lookup table
const colorramp = map(RGBA{Float32}, colormap("RdBu", 100))
function to_color(p::BilliardModels.Particle)
    l = (atan2(p.v.x, p.v.y) + pi) / 2pi
    colorramp[round(Int, clamp(l, 0, 1) * (length(colorramp)-1))+1]
end
function to_color(data, particles)
    @inbounds for (i,p) in enumerate(particles)
        data[i] = to_color(p)
    end
    data
end

cubecamera(window)

x0              = Vector2D(0.3, 0.1)
particles       = [BilliardModels.Particle(x0, Vector2D(1.0, 0.001*i)) for i=1:max_particles]
colors          = RGBA{Float32}[RGBA{Float32}(1., 0.1, clamp(0.001*i, 0.0, 1.0), 1.0) for i=1:max_particles]
particle_stream = const_lift(BilliardModels.step!, particles, table, timesignal)
v0              = map(to_points, particles)
vc0             = map(to_color, particles)
colors          = const_lift(to_color, vc0, particle_stream)
pointstream     = const_lift(to_points, v0, particle_stream)
primitive       = Circle(Point2f0(0), 0.05f0)

# we know that the particles will only be in this range
boundingbox = AABB{Float32}(Vec3f0(-pi), Vec3f0(2pi))
particles = visualize(
    (primitive, pointstream),
    color=colors, # set color array. This is per particle
    billboard=true, # set billboard to true, making the particles always face the camera
    boundingbox=Signal(boundingbox) # set boundingbox, to avoid bb re-calculation when particles update( is expensive)
)

# visualize the boundingbox
boundingbox = visualize(boundingbox, :lines)
# _view them (add them to the windows render list)
_view(particles, window, camera=:perspective)
_view(boundingbox, window, camera=:perspective)


if !isdefined(:runtests)
    renderloop(window)
end
