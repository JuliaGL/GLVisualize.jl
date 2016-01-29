using GLVisualize, Reactive, GeometryTypes, GLWindow, GLAbstraction

w = glscreen()

xhalf(r)    = SimpleRectangle(r.x,r.y, r.w÷2, r.h)
xhalf2(r)   = SimpleRectangle(r.w÷2, r.y, r.w÷2, r.h)
screen2D = Screen(w, name=:screen2D, area=const_lift(xhalf2, w.area))
screen3D = Screen(w, name=:screen3D, area=const_lift(xhalf, w.area))
robj = visualize(rand(Float32, 10,10))

view(robj, screen3D)
view(visualize(boundingbox(robj), :lines),method=:perspective, screen3D)
view(visualize([rand(Point2f0)*1000 for i=1:50], scale=Vec2f0(40)), screen2D)
renderloop(w)
