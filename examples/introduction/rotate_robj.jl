if !isdefined(:runtests)
	using GLVisualize, GLAbstraction
	using FileIO, GeometryTypes, Reactive
	window = glscreen()
	timesignal = loop(linspace(0f0,1f0,360))
end

mesh 			= loadasset("cat.obj")
rotation_angle  = const_lift(*, timesignal, 2f0*pi)
start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0))) # the cat needs some rotation on the x axis to stand straight
rotation 		= map(rotationmatrix_y, rotation_angle)
final_rotation 	= map(*, start_rotation, rotation)
robj 			= visualize(mesh, model=final_rotation)


view(robj, window)

if !isdefined(:runtests)
	renderloop(window)
end