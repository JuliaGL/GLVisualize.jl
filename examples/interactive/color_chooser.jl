using GLVisualize, Colors, GeometryTypes, Reactive

if !isdefined(:runtests)
    window = glscreen()
end
const record_interactive = true

color_s = Signal(RGBA{Float32}(1,0,0,1))
color_s, color_v = vizzedit(color_s, window)

view(color_v, window, camera=:fixed_pixel)

view(visualize(rand(Point2f0, 50_000) * 1000f0, scale=Vec2f0(5), color=color_s))

if !isdefined(:runtests)
    renderloop(window)
end
