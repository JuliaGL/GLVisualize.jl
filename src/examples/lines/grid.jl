using GLVisualize, GeometryTypes, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0.0, 1.0, 360))
end

description = """
Example to show how to set up a simple grid, usable for a 3D axis.
"""

_view(visualize(AABB{Float32}(Vec3f0(-2), Vec3f0(4)), :grid))

if !isdefined(:runtests)
    renderloop(window)
end
