using GLVisualize, GeometryTypes, GLAbstraction, ModernGL, FileIO, Reactive

if !isdefined(:runtests)
	window = glscreen()
	timesignal = loop(linspace(0f0, 1f0, 360))
end

let
rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

const b = Point3f0[(rand(Point3f0)*2)-1 for i=1:64]

sprites = visualize(
	(SimpleRectangle(0f0,0f0,0.5f0, 0.5f0), b),
	billboard=true, image=loadasset("foxy.png"),
	model=rotation
)

_view(sprites, window, camera=:perspective)
end

if !isdefined(:runtests)
	renderloop(window)
end
