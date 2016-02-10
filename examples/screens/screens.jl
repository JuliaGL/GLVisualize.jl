using GLVisualize, Reactive, GeometryTypes 
using GLWindow, GLAbstraction
	
if !isdefined(:runtests)
	window = glscreen()
end

"""
functions to halve some rectangle
"""
xhalf(r)  = SimpleRectangle(r.x, r.y, r.w÷2, r.h)
xhalf2(r) = SimpleRectangle(r.w÷2, r.y, r.w÷2, r.h)

# create first screen with window as the parent screen
# and a different area.
screen2D = Screen(
	window, name=:screen2D, 
	area=const_lift(xhalf2, window.area)
)
# create second screen with window as the parent screen
# and a different area.
screen3D = Screen(
	window, name=:screen3D, 
	area=const_lift(xhalf, window.area)
)

# create something to look at!
bars = visualize(rand(Float32, 10,10))
points = visualize([rand(Point2f0)*1000 for i=1:50], scale=Vec2f0(40))

# view them in different screens
view(bars,   screen3D, camera=:perspective)
view(points, screen2D, camera=:orthographic_pixel)

if !isdefined(:runtests)
	renderloop(window)
end
