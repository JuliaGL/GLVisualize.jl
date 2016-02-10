using GeometryTypes, GLAbstraction, Reactive,GLVisualize
w=glscreen()
N = 3
xls = linspace(-0.5, 4.5, N)
yls = linspace(2, 3, N)
zls = linspace(0, 1.77, N)

points = vec(Point3f0[Point3f0(x,y,z) for x=xls, y=yls, z=zls])
robj=visualize((HyperRectangle(Vec3f0(0), Vec3f0(0.1)), points))
println(boundingbox(robj).value)
view(robj)
view(visualize(boundingbox(robj), :lines), camera=:perspective)
GLWindow.renderloop(w)
