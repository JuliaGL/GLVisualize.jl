using Images, GeometryTypes, GLVisualize, Reactive, GLWindow, Colors
using GLAbstraction, GLFW
import GLAbstraction: imagespace, singlepressed
import GLVisualize: moving_average

if !isdefined(:runtests)
    window = glscreen()
end

color_a = Signal(RGBA{Float32}(1,0,0,1))
iconsize = 54
color_v, color_s = widget(color_a, window, area=(iconsize, iconsize))
edit_screen = Screen(window, area = map(window.area) do a
    SimpleRectangle(0, 0, a.w, iconsize)
end)
paint_screen = Screen(window, area = map(window.area) do a
    SimpleRectangle(0, iconsize, a.w, a.h-iconsize)
end)
GLVisualize.add_screen(paint_screen)

using Plots; glvisualize(size = widths(paint_screen))

plt = plot(rand(100));
gui() # tell Plots.jl to plot this in a window

# Plots creates subscreens in which it plots.
# We need to recover that screen
paint_screen = plt.o.children[1]

# create a clear canvas button (unchecked seems vaguely like a good symbol for an empty canvas)
buttobj, button_s = GLVisualize.button(loadasset("unchecked.png"), edit_screen)

# create a slider for the linewidth
slider_w, slider_s = GLVisualize.slider(
    linspace(0.5f0, 20f0, 100), edit_screen,
    thickness = 2f0,
    slider_length = 4 * iconsize,
    icon_size = Signal(iconsize)
)

# view and position them with layout!
_view(
    layout!(SimpleRectangle{Float32}(0, 0, iconsize, iconsize), color_v),
    edit_screen, camera=:fixed_pixel
)
_view(
    layout!(SimpleRectangle{Float32}(iconsize+2, 0, iconsize, iconsize), buttobj),
    edit_screen, camera=:fixed_pixel
)
# translate slider
set_arg!(slider_w, :model, translationmatrix(Vec3f0(iconsize*2+4, 0, 0)))

_view(
    slider_w,
    edit_screen, camera=:fixed_pixel
)

const linebuffer = Signal(fill(Point2f0(NaN), 4))
const colorbuffer = Signal(fill(value(color_s), 4))
const lineobj = visualize(
    linebuffer, :lines, color = colorbuffer,
    thickness = slider_s
)
_view(lineobj, paint_screen, camera=:perspective)

@materialize mouseposition, mouse_buttons_pressed, mouseinside = paint_screen.inputs

camera = paint_screen.cameras[:perspective]

const history = Point2f0[] # preallocate history for moving average

s = map(mouseposition, mouse_buttons_pressed, init=nothing) do mp, mbp
    l0, c0 = map(value, (linebuffer, colorbuffer))
    if singlepressed(mbp, GLFW.MOUSE_BUTTON_LEFT) && value(mouseinside)
        p = imagespace(mp, camera)
        keep, p = moving_average(p, 1.5f0, history)
        if keep
            push!(linebuffer, push!(l0, p))
            push!(colorbuffer, push!(c0, value(color_s)))
        end
    else
        if !isnan(last(l0)) # only push one NaN to seperate
            empty!(history) # reset
            push!(linebuffer, push!(l0, Point2f0(NaN)))
            push!(colorbuffer, push!(c0, value(color_s)))
        end
    end
    nothing
end
# preserve signals, so that it doesn't get garbage collected.
preserve(s)

# reset buffers
s2 = map(button_s) do clicked
    if clicked
        push!(linebuffer, fill(Point2f0(NaN), 4))
        push!(colorbuffer, fill(value(color_s), 4))
    end
    nothing
end
preserve(s2)

if !isdefined(:runtests)
    renderloop(window)
end
