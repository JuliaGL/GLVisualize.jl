using GLVisualize, GLAbstraction, Colors, Reactive, GeometryTypes
w=glscreen()
function xy_data(x,y,i, N)
	x = ((x/N)-0.5f0)*i
	y = ((y/N)-0.5f0)*i
	r = sqrt(x*x + y*y)
	Float32(sin(r)/r)
end
surf(i, N) = Float32[xy_data(Float32(x),Float32(y),Float32(i), N) for x=1:N, y=1:N]
t = bounce(20f0:0.5f0:60f0)
bb = Signal(AABB{Float32}(Vec3f0(0), Vec3f0(1)))
view(visualize(const_lift(surf, t, 400), :surface, boundingbox=bb))
renderloop(w)
