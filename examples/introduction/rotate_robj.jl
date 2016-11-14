using GLVisualize, GLAbstraction
using FileIO, GeometryTypes, Reactive

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end
description = """
Introductory example, explaining Signals, file loading and
how to transform a visualization.
"""

# loadasset is defined in GLVisualize like this:
# loadasset(path_segments...) = FileIO.load(assetpath(path_segments...))
# where assetpath just looks up the file in the asset folder
# You can load these (file types)[https://github.com/JuliaIO/FileIO.jl/blob/master/docs/registry.md]
mesh = loadasset("cat.obj")

# GLAbstraction.const_lift is an alias for Reactive.map, which also works for non
# signal arguments.
# Reactive.map takes a function and signals like the one created via `loop` (or just Signal(x))
# as an argument, applies the function to the signals whenever they update and
# returns a new signal.

rotation_angle  = const_lift(*, timesignal, 2f0*pi)

# the cat needs some rotation on the x axis to stand straight
# so we start off with a rotation of 90 degrees
start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0)))
rotation        = map(rotationmatrix_y, rotation_angle)
final_rotation  = map(*, start_rotation, rotation)

# now we visualize the mesh and pass the rotation via the model keyword argument,
# which is short for the modelmatrix, which allows you to transform the visualization
# with any arbitrary transformation matrix
# You can create the most common transformation matrix with `translationmatrix(::Vec3f0)`,
# `rotationmatrix_x`/`y`/`z` (rotation around axis x,y,z), and `scalematrix(::Vec3f0)`

# the visualize function always only takes one argument, plus an optional style
# argument and then visualization dependant many keywords to customize the visualization.
# for all parameters Signals can be used and thus the visualization becomes animated

robj = visualize(mesh, model = final_rotation)


_view(robj, window)

if !isdefined(:runtests)
    renderloop(window)
end
