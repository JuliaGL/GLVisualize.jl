using GLVisualize, GeometryTypes, GLAbstraction
using Colors, Reactive, FileIO

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end

description = """
Example showing how rotate 2D particles and animate their scale.
"""

t          = const_lift(*, timesignal, 10f0)
radius     = 200f0
w,h        = widths(window)
middle     = Point2f0(w/2, h/2)
circle_pos = Point2f0[(Point2f0(sin(i), cos(i))*radius)+middle for i=linspace(0, 2pi, 20)]
rotation   = Vec2f0[normalize(Vec2f0(middle)-Vec2f0(p)) for p in circle_pos]
scales     = map(t) do t
    Vec2f0[Vec2f0(30, ((sin(i+t)+1)/2)*60) for i=linspace(0, 2pi, 20)]
end

circles = visualize(
    (CIRCLE, circle_pos),
    rotation=rotation, scale=scales,
)

_view(circles, window)

if !isdefined(:runtests)
    renderloop(window)
end
