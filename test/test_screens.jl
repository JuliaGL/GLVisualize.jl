using GLVisualize, Reactive, GeometryTypes, GLWindow, ColorTypes

const rs    = GLVisualize.ROOT_SCREEN
xhalf(r)    = Rectangle{Int}(r.x,r.y, r.w/2, r.h)
xhalf2(r)   = Rectangle{Int}(r.w/2, r.y, r.w/2, r.h)
const screen3D = Screen(rs, area=lift(xhalf, rs.area))
const screen2D = Screen(rs, area=lift(xhalf2, rs.area))

println(screen3D.area)
println(screen2D.area)

view(visualize(rand(Float32, 10,10)), screen3D)
view(visualize(rand(Float32, 10,10)), screen2D)

view(visualize(lift(x->Rectangle(0,0,x.w, x.h), screen2D.area), color=RGBA(1f0,0f0,1f0,1f0)), screen2D, method=:fixed_pixel)
view(visualize(lift(x->Rectangle(0,0,x.w, x.h), screen3D.area), color=RGBA(0f0,0f0,1f0,1f0)), screen3D, method=:fixed_pixel)



renderloop()