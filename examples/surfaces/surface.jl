if !isdefined(:runtests)
	using GLVisualize, GLAbstraction, Colors, Reactive, GeometryTypes
	window = glscreen()
	timesignal = loop(linspace(0f0,1f0,360))
end

# generate some pretty data
function xy_data(x,y,i, N)
	x = ((x/N)-0.5f0)*i
	y = ((y/N)-0.5f0)*i
	r = sqrt(x*x + y*y)
	Float32(sin(r)/r)
end

surf(i, N) = Float32[xy_data(x, y, i, N) for x=1:N, y=1:N]

t = map(t->(t*30f0)+20f0, timesignal)

bb = Signal(AABB{Float32}(Vec3f0(0), Vec3f0(1)))

view(visualize(const_lift(surf, t, 400), :surface, boundingbox=bb))

if !isdefined(:runtests)
	renderloop(window)
end
