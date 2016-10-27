module TestModule
    const runtests = true
    include(Pkg.dir("GLVisualize", "src", "examples", "parallel", "simulation3d.jl"))
end


using GLVisualize, GLWindow
window = glscreen();@async renderloop(window)

a, b = y_partition(window.area, 10)
toolbar = Screen(window,
    area=a, color = RGBA(0.95f0, 0.95f0, 0.95f0, 1.0f0)
)
window = Screen(window,
    area=b
)
