using Images, GeometryTypes, GLVisualize, Reactive, GLWindow, Colors
using FixedSizeArrays, GLAbstraction

if !isdefined(:runtests)
    window = glscreen()
end

empty!(window)


color_a = Signal(RGBA{Float32}(1,0,0,1))
iconsize = 54
color_s, a_v = widget(color_a, window, area=(iconsize, iconsize))
edit_screen = Screen(window, area=map(window.area) do a
    SimpleRectangle(0, 0, a.w, iconsize)
end)
paint_screen = Screen(window, area=map(window.area) do a
    SimpleRectangle(0, iconsize, a.w, a.h-iconsize)
end)
GLVisualize.add_screen(paint_screen)


using Plots; glvisualize(size=widths(paint_screen))
plt = plot(rand(100));
gui()
paint_screen = plt.o.children[1]
buttobj, button_s = GLVisualize.button(loadasset("unchecked.png"), edit_screen)

slider_s, slider_w = GLVisualize.slider(
    linspace(0.5f0, 20f0, 100), edit_screen,
    play_signal=Signal(false),
    slider_length=4*iconsize,
    icon_size=Signal(iconsize)
)


_view(
    layout!(SimpleRectangle{Float32}(0,0,iconsize,iconsize), a_v),
    edit_screen, camera=:fixed_pixel
)
_view(
    layout!(SimpleRectangle{Float32}(iconsize+2,0,iconsize,iconsize), buttobj),
    edit_screen, camera=:fixed_pixel
)
set_arg!(slider_w, :model, translationmatrix(Vec3f0(iconsize*2+4, 0, 0)))

_view(
    slider_w,
    edit_screen, camera=:fixed_pixel
)

const linebuffer = Signal(fill(Point2f0(NaN), 4))
const colorbuffer = Signal(fill(value(color_s), 4))
const lineobj = visualize(
    linebuffer, :lines, color=colorbuffer,
    thickness=slider_s
)
_view(lineobj, paint_screen, camera=:fixed_pixel)



@materialize mouseposition, mouse_buttons_pressed, mouseinside = paint_screen.inputs

s = map(mouseposition, mouse_buttons_pressed, init=nothing) do mp, mbp
    l0, c0 = map(value, (linebuffer, colorbuffer))
    if !isempty(mbp) && value(mouseinside)
        push!(linebuffer, push!(l0, Point2f0(mp)))
        push!(colorbuffer, push!(c0, value(color_s)))
    else
        if !isnan(last(l0)) # only push one NaN to seperate
            push!(linebuffer, push!(l0, Point2f0(NaN)))
            push!(colorbuffer, push!(c0, value(color_s)))
        end
    end
    nothing
end
preserve(s)
s2 = map(button_s, init=nothing) do clicked
    if clicked
        push!(linebuffer, fill(Point2f0(NaN), 4))
        push!(colorbuffer, fill(value(color_s), 4))
    end
    nothing
end
preserve(s2)


if !isdefined(:runtests)
    @async renderloop(window)
end
r = a_v.children[]
r[:model]
