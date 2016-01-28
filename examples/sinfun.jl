using GLVisualize, GeometryTypes, Colors, GLAbstraction
w = glscreen()

n = 50
const yrange = linspace(0.03, 0.3, n)
trange = linspace(0, 10pi, 200)

function gen_points(t, y)
    x = sin(t+(y*60*pi*y))*y*5
    z = cos(t+(y*60*pi*y))*y*5
    Point3f0(x,y*60f0,z)
end
function gen_points(t)
    Point3f0[gen_points(t, y) for y in yrange]
end
t         = bounce(trange)
positions = map(gen_points, t)
scale     = map(Vec3f0, yrange)
primitive = centered(Sphere)
view(visualize((primitive, positions), scale=scale))
renderloop(w)
