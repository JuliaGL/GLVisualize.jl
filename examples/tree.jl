using GeometryTypes, GLAbstraction, Reactive

depth 	  = 5
branching = 3

points = Array(Point3f0, (5^4)+2)
points[1] = Point3f0(0,0,0)
points[2] = Point3f0(1,0,0)
z = 2
oldz = z
for d=1:depth
	base_range = oldz:z
	oldz = z
	base_1 = points[oldz-1]
	for base in sub(points, base_range)
		for j=linspace(0f0, pi, branching)
			base_dir = base-base_1
			points[z] = base + (Point3f0(0, sin(j)/depth, cos(j)/depth) + (base_dir*0.8f0))
			z += 1
		end
	end
end

using GLVisualize
w,r=glscreen()
view(visualize(points))
#view(visualize(Signal(points), :lines), method=:perspective)

r()