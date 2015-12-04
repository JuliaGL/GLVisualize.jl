
using ModernGL
using FileIO, MeshIO, GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes, Colors
using Base.Test
function test()
    w, renderloop = glscreen()

    global TEST_DATA   = Context[]
    global TEST_DATA2D = Context[]

    include(string("all_tests.jl"))

    grid    = vcat(TEST_DATA2D, TEST_DATA)
    #grid2D  = reshape(grid, close_to_square(length(grid)))
    println("reshape done")

    view(visualize(grid), w, method=:orthographic_pixel)
    glClearColor(1,1,1,1)

    renderloop()
end
test()
