using GLVisualize, GeometryTypes, FileIO
using GLAbstraction, Colors, Reactive
if !isdefined(:runtests)
	window = glscreen()
	timesignal = bounce(0f0:0.1:1f0)
end

primitive = SimpleRectangle(0f0,-0.5f0,1f0,1f0)
positions = rand(10f0:0.01f0:200f0, 10)

function interpolate(a, positions, t)
    [ae+((be-ae)*t) for (ae, be) in zip(a,positions)]
end
t = const_lift(*, timesignal, 10f0)
interpolated = foldp((positions,positions,positions), t) do v0_v1_ip, td
    v0,v1,ip = v0_v1_ip
    pol = td%1
    if isapprox(pol, 0.0)
        v0 = v1
        v1 = map(x-> rand(linspace(-50f0, 60f0, 100)), v0)
    end
    v0, v1, interpolate(v0, v1, pol)
end
b_sig = map(last, interpolated)
bars = visualize(
    (RECTANGLE, b_sig),
    intensity=b_sig,
    ranges=linspace(0,600, 10),
    color_norm=Vec2f0(-40,200),
    color_map=GLVisualize.default(Vector{RGBA})
)
_view(bars, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
	renderloop(window)
end
