using ModernGL
using FileIO, MeshIO, GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes, Colors
using Base.Test

is_ci() = (
    get(ENV, "TRAVIS", "") == "true" || 
    get(ENV, "APPVEYOR", "") == "true" || 
    get(ENV, "CI", "") == "true"
)

function test()
    w, renderloop = glscreen()

    global TEST_DATA   = RenderObject[]
    global TEST_DATA2D = RenderObject[]

    include(string("all_tests.jl"))

    grid    = vcat(TEST_DATA2D, TEST_DATA)
    grid2D  = reshape(grid, close_to_square(length(grid)))
    println("reshape done")

    view(visualize(grid2D), w, method=:perspective)
    glClearColor(1,1,1,1)

    renderloop()
end

# only do test if not CI... this is for automated testing environments which fail for OpenGL stuff, but I'd like to test if at least including works
!is_ci() && test()
   




