using Contour, GLVisualize, GeometryTypes, GLAbstraction
xrange = -5f0:0.02f0:5f0
yrange = -5f0:0.02f0:5f0

z = Float32[sin(1.3*x)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x) for x in xrange, y in yrange]
mini = minimum(z)
maxi = maximum(z)
w = glscreen()

trans = Vec3f0(0)
for h in mini:0.2f0:maxi
    c = contour(xrange, yrange, z, h)
    for elem in c.lines
        points = map(elem.vertices) do p
            Point3f0(p, h+0.0001f0)
        end
        view(visualize(points, :lines), method=:perspective)
        view(visualize(elem.vertices, :lines, model=translationmatrix(Vec3f0(0,11,0))), method=:perspective)
    end
end
trans += Vec3f0(11,0,0)
view(visualize(
    z, :surface, grid_start=(-5,-5), grid_size=(10, 10),
    model=translationmatrix(trans)
))


trans += Vec3f0(0,11,0)

view(visualize(
    reinterpret(Intensity{1,Float32}, z), grid_start=(-5,-5), grid_size=(10, 10),
    model=translationmatrix(trans)

), method=:perspective)


renderloop(w)
