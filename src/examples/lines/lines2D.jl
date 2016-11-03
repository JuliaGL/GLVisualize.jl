using GLVisualize, GeometryTypes, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0.0, 1.0, 360))
end

description = """
Animated and coloured lines.
"""
const N = 2048


function spiral(i, start_radius, offset)
    Point2f0(sin(i), cos(i)) * (start_radius + ((i/2pi)*offset))
end
const wh = widths(window)
# 2D particles
curve_data(i, N) = Point2f0[spiral(i+x/20f0, 1, (i/20)+1)+Point2f0(wh)/2f0 for x=1:N]

t = const_lift(x-> (1f0-x)*100f0, timesignal)
color = map(RGBA{Float32}, colormap("Blues", N))
_view(visualize(const_lift(curve_data, t, N), :lines, color=color))


if !isdefined(:runtests)
    renderloop(window)
end
