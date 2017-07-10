using GLVisualize, GeometryTypes, FileIO
using GLAbstraction, Colors, Reactive
if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(0f0:0.1:1f0)
end

description = """
Example how to animate a 2D barplot.
"""

primitive = SimpleRectangle(0f0, -0.5f0, 1f0, 1f0)
scalars = rand(10f0:0.01f0:200f0, 200)

function interpolate(a, scalars, t)
    [ae + ((be - ae) * t) for (ae, be) in zip(a, scalars)]
end
t = const_lift(*, timesignal, 10f0)
v0 = (scalars, rand(10f0:0.01f0:200f0, 200), scalars)
interpolated = foldp(v0, t) do v0_v1_ip, td
    v0, v1, ip = v0_v1_ip
    pol = td % 1
    if isapprox(pol, 0.0)
        v0 = v1
        v1 = map(x-> rand(linspace(-50f0, 60f0, 100)), v0)
    end
    v0, v1, interpolate(v0, v1, pol)
end
b_sig = map(last, interpolated)
bars = visualize(
    (RECTANGLE, b_sig),
    ranges = linspace(0, 600, 10),
    color_norm = Vec2f0(-40, 200),
    color_map = GLVisualize.default(Vector{RGBA})
)


_view(bars, window, camera = :orthographic_pixel)
if !isdefined(:runtests)
    renderloop(window)
end
