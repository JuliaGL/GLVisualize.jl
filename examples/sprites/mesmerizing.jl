using GLVisualize, GeometryTypes, Colors
using GLAbstraction
if !isdefined(:runtests)
	window = glscreen()
	timesignal = bounce(linspace(0f0,1f0,360))
end

description = """
Animated 2D particles in 3D space with glow.
"""

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

t = const_lift(*, 1000f0, timesignal)
ps1 = const_lift(sin_torus, 2, 6, 10, t)
ps2 = const_lift(sin_torus, 5, 4, 10, t)
ps3 = const_lift(sin_torus, 10, 2, 10, t)
ps = map(vcat, ps1, ps2, ps3)
l1, l2, l3 = map(x->length(value(x)), (ps1, ps2, ps3))
colors = [
    fill(RGBA(0.9f0, 0f0, 0.7f0, 1f0), l1);
    fill(RGBA(0.7f0, 0.2f0, 0.8f0, 1f0), l2);
    fill(RGBA(1.0f0, 0.4f0, 0.95f0, 1f0), l3);
]
scales = [
    fill(Vec2f0(0.1), l3);
    fill(Vec2f0(0.05), l2);
    fill(Vec2f0(0.04), l1);
]

_view(visualize(
    (Circle, ps),
    glow_color = RGBA(0.8f0, 0.6f0, 0.95f0, 0.8f0),
    glow_width = const_lift(/, timesignal, 20f0),
    scale = scales, color = colors
), camera=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
