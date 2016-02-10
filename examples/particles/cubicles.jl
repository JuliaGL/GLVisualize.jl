if !isdefined(:runtests)
	using GLVisualize, GeometryTypes, FileIO
	using GLAbstraction, Colors, Reactive
	window = glscreen()
	timesignal = loop(0:0.1:1)
end

cube = HyperRectangle(Vec3f0(0), Vec3f0(0.05))
n = 20
const wx,wy,wz = widths(cube)

mesh = GLNormalMesh(cube)
function position(timesignal, x, y)
    pos = Point3f0(x*(sqrt(wx^2+wy^2)), -y*wy, y*wz)
    dir = Point3f0(0, wy, wz)
    pos = pos + sin(timesignal)*dir
end
position_signal = map(timesignal) do t
    vec(Point3f0[position(t,x,y) for x=1:n, y=1:n])
end

rotation = map(timesignal) do t
    vec(Vec3f0[Vec3f0(cos(t+(x/7)),sin(t+(y/7)), 1) for x=1:20, y=1:20])
end

cubes = visualize((mesh, position_signal), rotation=rotation)

view(cubes, window, camera=:perspective)

if !isdefined(:runtests)
	renderloop(window)
end