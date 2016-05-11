using GLVisualize, GeometryTypes, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0.0, 1.0, 360))
end

view(visualize(AABB{Float32}(Vec3f0(-2), Vec3f0(4)), :grid))

if !isdefined(:runtests)
    renderloop(window)
end

window.renderlist[1][1][:grid_color] = RGBA{Float32}(0.8,0.8,0.8,1)
window.renderlist[1][1][:bg_color] = RGBA{Float32}(1,1,1,0)
window.renderlist[1][1][:grid_thickness] = Vec3f0(0.999)
