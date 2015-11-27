using GLVisualize, Reactive, GeometryTypes, GLWindow, GLAbstraction
 
w,r = glscreen()

xhalf(r)    = SimpleRectangle(r.x,r.y, r.w÷2, r.h)
xhalf2(r)   = SimpleRectangle(r.w÷2, r.y, r.w÷2, r.h)
const screen3D = Screen(w, area=const_lift(xhalf, w.area))
const screen2D = Screen(w, area=const_lift(xhalf2, w.area))

view(visualize(rand(Float32, 10,10)), screen3D)
view(visualize([rand(Point2f0)*1000 for i=1:50]), screen2D)

r()