using GLVisualize, GeometryTypes
using GLAbstraction
w = glscreen();@async renderloop(w)

function sin_torus(radius, thickness, N, t)
    pirange = linspace(0, 2pi, N^2)
    points = zeros(Point3f0, N^2)
    p,q = 6,9
    for (i,x)=enumerate(pirange)
        r = cos(q*(x+t))+thickness
        points[i] = Point3f0(r*cos(p*x),r*sin(p*x), -sin(q*x))/radius
    end
    points
end
ps1 = const_lift(sin_torus, 2, 6, 10, bounce(linspace(0,pi, 1000)))
ps2 = const_lift(sin_torus, 5, 4, 10, bounce(linspace(0,pi, 1000)))
ps3 = const_lift(sin_torus, 10, 2, 10, bounce(linspace(0,pi, 1000)))
ps = map(vcat, ps1, ps2, ps3)
empty!(w)
view(visualize((Circle, ps), scale=Vec2f0(0.04), billboard=true), camera=:perspective)
