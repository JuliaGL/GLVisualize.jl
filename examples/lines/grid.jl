using GLVisualize, GeometryTypes, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0.0, 1.0, 360))
end
view(visualize(AABB{Float32}(Vec3f0(-2), Vec3f0(2)), :grid, color=color))


if !isdefined(:runtests)
    renderloop(window)
end
