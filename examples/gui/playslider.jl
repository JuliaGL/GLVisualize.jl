using GLVisualize, GLAbstraction, Reactive, GeometryTypes, Colors, GLWindow
import GLVisualize: widget, mm, play_slider

if !isdefined(:runtests)
    window = glscreen()
end

description = """
Usage of the play slider widget
"""

iconsize = 8mm
editarea, viewarea = x_partition_abs(window.area, round(Int, 8.2 * iconsize))
edit_screen = Screen(window, area = editarea)
viewscreen = Screen(window, area = viewarea)

function xy_data(x,y,i, N)
    x = ((x/N)-0.5f0)*i
    y = ((y/N)-0.5f0)*i
    r = sqrt(x*x + y*y)
    Float32(sin(r)/r)
end
surf(i, N) = Float32[xy_data(x, y, i, N) for x=1:N, y=1:N]

play_viz, slider_value = play_slider(
    edit_screen, iconsize, linspace(1f0, 50f0, 100)
)
color_viz, color_s = widget(RGBA{Float32}.(colormap("Blues", 7)), edit_screen)

# startstop is not needed here, since the slider value will start and stop
my_animation = map(slider_value) do t
    surf(t, 128)
end

# pair of name => any visualization object
# will be layouted nicely
controls = Pair[
    "color" => color_viz,
    "play" => play_viz,
]

_view(visualize(my_animation, :surface, color_map = color_s), viewscreen)
_view(visualize(
    controls,
    text_scale = 4mm,
    width = 8iconsize
), edit_screen, camera = :fixed_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
