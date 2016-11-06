using GLVisualize, GeometryTypes, Colors
using Reactive, GLAbstraction

if !isdefined(:runtests)
	window = glscreen()
	timesignal = loop(linspace(0f0, 1f0, 360))
end

description = """
Example demoing the linesegment visualization and how to use indices to connect
points with line segments. Indices can be used like this on other primitives,
E.g. particles and the normal line type.
"""

large_sphere = HyperSphere(Point3f0(0), 1f0)
rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

positions = decompose(Point3f0, large_sphere)
indices = rand(range(Cuint(0), Cuint(length(positions))), 1000)

color = map(large_sphere->RGBA{Float32}(large_sphere, 0.9f0), colormap("Blues", length(positions)))
color2 = map(large_sphere->RGBA{Float32}(large_sphere, 1f0), colormap("Blues", length(positions)))

lines = visualize(
	positions, :linesegment, thickness=0.5f0,
	color=color, indices=indices, model=rotation
)
spheres = visualize(
	(Sphere{Float32}(Point3f0(0.0), 1f0), positions),
	color=color2, scale=Vec3f0(0.05), model=rotation
)
_view(lines, window, camera=:perspective)
_view(spheres, window, camera=:perspective)


if !isdefined(:runtests)
	renderloop(window)
end
