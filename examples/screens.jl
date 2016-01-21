using GLVisualize, Reactive, GeometryTypes, GLWindow, GLAbstraction

w = glscreen()

xhalf(r)    = SimpleRectangle(r.x,r.y, r.w÷2, r.h)
xhalf2(r)   = SimpleRectangle(r.w÷2, r.y, r.w÷2, r.h)
const screen2D = Screen(w, name=:screen2D, area=const_lift(xhalf2, w.area))
const screen3D = Screen(w, name=:screen3D, area=const_lift(xhalf, w.area))

view(visualize(rand(Float32, 10,10)), screen3D)
view(visualize([rand(Point2f0)*1000 for i=1:50], scale=Vec2f0(40)), screen2D)
@async GLWindow.renderloop(w)
