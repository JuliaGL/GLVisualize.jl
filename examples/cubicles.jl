using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO

cube = HyperRectangle(Vec3f0(0), Vec3f0(0.05))
const n = 20
const wx,wy,wz = widths(cube)


w = glscreen()
mesh=GLNormalMesh(cube)
t = loop(0:0.1:pi)
function position(t, x, y)
    pos = Point3f0(x*(sqrt(wx^2+wy^2)), -y*wy, y*wz)
    dir = Point3f0(0, wy, wz)
    pos = pos + sin(t)*dir
end
const points = map(t) do t
    vec(Point3f0[position(t,x,y) for x=1:n, y=1:n])
end

rotation = map(t) do t
    vec(Vec3f0[Vec3f0(cos(t+(x/7)),sin(t+(y/7)), 1) for x=1:20, y=1:20])
end

view(visualize((mesh, points), rotation=rotation))


GLWindow.renderloop(w)
