using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO

cube = HyperRectangle(Vec3f0(0), Vec3f0(0.05))
wx,wy,wz = widths(cube)

const points = vec(Point3f0[Point3f0(x*(sqrt(wx^2+wy^2)), -y*wy, y*wz) for x=1:20, y=1:20])

w = glscreen()
mesh=GLNormalMesh(cube)

rotation = map(bounce(0:0.1:2pi)) do x
    Vec3f0(x,0,1)
end

view(visualize((mesh, points), rotation=rotation))

axis_points = Point3f0[
    (0,0,0), (1,0,0),
    (0,0,0), (0,1,0),
    (0,0,0), (0,0,1),
]
const C = RGBA{Float32}
axis_color = C[
    C(1,0,0,1), C(1,0,0,1),
    C(0,1,0,1), C(0,1,0,1),
    C(0,0,1,1), C(0,0,1,1),
]

view(visualize(axis_points, :linesegment, color=axis_color), method=:perspective)



GLWindow.renderloop(w)
