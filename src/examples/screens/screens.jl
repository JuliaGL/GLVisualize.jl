using GLVisualize, Reactive, GeometryTypes
using GLWindow, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
end

description = """
Example showing how to create different screens.
"""


ctrla, viewa = y_partition(window.area, 20)
view2da, view3da = x_partition(window.area, 50)

ctrlscreen = Screen(
    window, name=:ctrlscreen, color=RGBA(0.9f0, 0.9f0, 0.9f0, 1f0),
    area=ctrla
)
viewscreen = Screen(
    window, name=:viewscreen,
    area=viewa
)
# create first screen with window as the parent screen
# and a different area.
screen2D = Screen(
    viewscreen, name=:screen2D, color=RGBA(1f0, 0.9f0, 1f0, 1f0),
    area=view2da
)
# create second screen with window as the parent screen
# and a different area.
screen3D = Screen(
    viewscreen, name=:screen3D, color=RGBA(0.9f0, 0.9f0, 1f0, 1f0),
    area=view3da
)

# create something to look at!
bars = visualize(rand(Float32, 10,10))
points = visualize([rand(Point2f0)*1000 for i=1:50], scale=Vec2f0(40))

# _view them in different screens
# _view them in different screens
_view(bars,   screen3D, camera=:perspective)
_view(points, screen2D, camera=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
