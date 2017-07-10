using GLVisualize, GeometryTypes, Reactive, GLAbstraction

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end

description = """
Efficiently animated 3D unicode arrow field
"""

# let the visualization rotate later on
rotation = map(rotationmatrix_z, const_lift(*, timesignal, 2f0 * pi))
# create some random 3D vectors
vectors3d = rand(Vec3f0, 5, 5, 5)
# this is not the best way to use 2D sprites, but this will space them on
# a 3D grid and use the rotation from `vectors3d` and the length of them
# to look up the a color from the optional keyword argument `color_map`.
arrows = visualize(('➤', vectors3d), scale = Vec2f0(0.1), model = rotation)

_view(arrows, camera = :perspective)

if !isdefined(:runtests)
    renderloop(window)
end
