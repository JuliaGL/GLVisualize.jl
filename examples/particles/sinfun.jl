using GLVisualize, GeometryTypes, Colors, GLAbstraction

if !isdefined(:runtests)
	window = glscreen()
	timesignal = bounce(linspace(0f0,1f0,360))
end

t = const_lift(*, timesignal, 20pi)
n = 50
const yrange = linspace(0.03, 0.3, n)
trange = linspace(0, 10pi, 200)

function gen_points(timesignal, y)
    x = sin(timesignal+(y*60*pi*y)+y)*y*5
    z = cos((timesignal+pi)+(y*60*pi*y)+y)*y*5
    Point3f0(x,y*60f0,z)
end
function gen_points(timesignal)
    Point3f0[gen_points(timesignal, y) for y in yrange]
end

positions = map(gen_points, t)
scale     = map(Vec3f0, linspace(0.05, 0.6, n))
primitive = centered(Sphere)
color     = map(RGB{Float32}, colormap("RdBu", n))
points 	  = visualize((primitive, positions), scale=scale, color=color)

view(points, window)

if !isdefined(:runtests)
	renderloop(window)
end
