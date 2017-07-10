using GLVisualize, GeometryTypes, Colors, GLAbstraction, Reactive, Images, ModernGL
import GLVisualize: mm, annotated_text

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end

description = """
Example of showing animated annotations over an image stream
"""

N = 20
positions = foldp(rand(Point2f0, N) .* 500f0, timesignal) do v0, t
    map!(v0) do p
        map(p .+ (rand(Point2f0) .- 0.5f0) .* 10f0) do pi
            clamp(pi, 0f0, 500f0) # restrict to image
        end
    end
end
base = [string(i) for i=1:N]
label_str = foldp(copy(base), timesignal) do v0, t
    map!(v0, base) do baselabel
        string(baselabel, ' ', round(t, 3))
    end
end

labels, widths = annotated_text(positions, label_str)
fbuffer = foldp(rand(RGB{N0f8}, 500, 500), timesignal) do v0, t
    map!(v0) do v
        RGB(v.r > 0.5 ? sin(v.r) : cos(v.r), (sin(t) + 1) / 2, 0.7) # yeah, real creative..
    end
end
frame_viz = visualize(fbuffer)

# instead of circle you can also use unicode charactes (e.g. '+')
position_viz = visualize(
    (Circle{Float32}(Point2f0(0), 1.5mm), positions),
    color = RGBA(1f0, 0f0, 0f0, 0.6f0)
)
gpu_position = position_viz.children[][:position]
bg_viz = visualize(
    (ROUNDED_RECTANGLE, gpu_position),
    scale = widths,
    # you can give each label a color (random looks terrible, which is why whe use just white instead)
    # color = RGBA{Float32}[rand(RGB) for i = 1:N],
    color = RGBA(1f0, 1f0, 1f0, 0.6f0),
    offset = Vec2f0(1.0mm)
)
_view(frame_viz, window)
_view(bg_viz, window)
_view(labels, window)
_view(position_viz, window)

center!(window, :orthographic_pixel) # center orthographic_pixel camera to what we just visualized

if !isdefined(:runtests)
    renderloop(window)
end
