using GLVisualize, GeometryTypes, Colors, GLAbstraction

if !isdefined(:runtests)
	window = glscreen()
	timesignal = bounce(linspace(0,1,360))
end

t = const_lift(*, timesignal, 2pi)
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

positions = map(gen_points, timesignal)
scale     = map(Vec3f0, yrange)
primitive = centered(Sphere)
points 	  = visualize((primitive, positions), scale=scale)

view(points, window)

if !isdefined(:runtests)
	renderloop(window)
end