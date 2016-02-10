if !isdefined(:runtests)
	using GLVisualize, GeometryTypes
	window = glscreen()
end

xrange = -5f0:0.02f0:5f0
yrange = -5f0:0.02f0:5f0

z = Intensity{1,Float32}[sin(1.3*x)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x) for x in xrange, y in yrange]

renderable = visualize(z)

view(renderable, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
	renderloop(window)
end
