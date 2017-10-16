using Images, Colors, GeometryTypes
using Reactive, FileIO, GLVisualize
using GLAbstraction, GeometryTypes, GLWindow, ImageFiltering
window = glscreen()
slider, slider_s = widget(Signal(1f0), range = 0.1f0:0.1f0:1.0f0, window)

f(x,y) = (x,y) == (0,0) ? 0 : -x*y/(x^2 + y^2)

function graph_polar(rad)
    rv = linspace(0,rad,10)
    θv = linspace(0,2π,10)
    xv = Float32[r*cos(θ) for r=rv, θ=θv]
    yv = Float32[r*sin(θ) for r=rv, θ=θv]
    zv = Float32[f(r*cos(θ),r*sin(θ)) for r = rv, θ = θv];
    return (xv,yv,zv)
end

function graph_cartesian(a)
    zv = Float32[f(x,y) for x=linspace(-a,a,20),y=linspace(-a,a,20)];
    return zv
end

startvalue = graph_polar(1.0)
task, surfsig = async_map(graph_polar, startvalue, slider_s)

image_renderable = visualize(
    (map(first, surfsig), map(x-> getindex(x, 2), surfsig), map(last, surfsig)), :surface,
    color_map = GLVisualize.default(Vector{RGBA}, Style(:default)),
    wireframe = true, color = nothing, color_norm = Vec2f0(-0.4, 0.4)
)

w = widths(value(boundingbox(slider)))
h = round(Int, w[2])

slider_screen = Screen(window, area = map(window.area) do a
    SimpleRectangle(0, 0, a.w, h)
end)

image_screen = Screen(window, area = map(window.area) do a
    SimpleRectangle(0, h, a.w, a.h-h)
end)

_view(slider, slider_screen, camera = :fixed_pixel)
_view(image_renderable, image_screen, camera = :perspective)

renderloop(window)
