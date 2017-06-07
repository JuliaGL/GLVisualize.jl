using GLVisualize, Reactive, GeometryTypes
using GLWindow, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
end

description = """
Example showing how to create different screens.
"""

# partition the main window into 4 areas
# The result is an area signal (::Signal{SimpleRectangle})
# Which will cover 20% (50%) percent of the parent area, and will adapt when
# the parent resizes. There is also y/x_partition_abs, which will not resize and
# the units are absolute pixel values.
texta, viewa = y_partition(window.area, 20)
view2da, view3da = x_partition(viewa, 50)

# create a couple of screens from these areas
textscreen = Screen(
    window, name = :text, color = RGBA(0.85f0, 0.85f0, 0.85f0, 1f0),
    area = texta
)

viewscreen = Screen(
    window, name = :viewscreen,
    area = viewa
)
# create first screen with window as the parent screen
# and a different area.
screen2D = Screen(
    viewscreen, name = :screen2D, color = RGBA(1f0, 0.9f0, 1f0, 1f0),
    area = view2da
)
# create second screen with window as the parent screen
# and a different area.
screen3D = Screen(
    viewscreen, name = :screen3D, color = RGBA(0.9f0, 0.9f0, 1f0, 1f0),
    area = view3da
)

# create something to look at!
bars = visualize(rand(Float32, 10, 10))
points = visualize([rand(Point2f0) * 1000 for i=1:50], scale = Vec2f0(40))
text = visualize("Bottom Screen! =)", color = RGBA(1f0, 1f0, 1f0))

# _view them in different screens
_view(bars,   screen3D, camera = :perspective)
_view(points, screen2D, camera = :orthographic_pixel)
_view(text, textscreen, camera = :orthographic_pixel)
# center to the render objects (the text) in the textscreen.
# don't zoom exactly to that boundingbox, though, and leave a border!
center!(textscreen, :orthographic_pixel, border = 8)

if !isdefined(:runtests)
    renderloop(window)
end
