using GLVisualize, GeometryTypes, Colors




function visu(x, sym=:default)
    tic()
    @profile r = visualize(x, sym)
    t = toq()
    println("visualize $t")
    tic()
    @profile _view(r)
    t = toq()
    println("view $t")
    tic()
    r = visualize(x, sym, boundingbox=nothing, color=RGBA{Float32}(0,0,0,0))
    t = toq()
    println("no bb $t")
end

function test(w)
    x = rand(Float32, 10, 10)
    visu(x)
    visu(x, :surface)
    visu((x,x,x), :surface)

    y = rand(Point3f0, 10)
    visu(y)
    visu((GLVisualize.CIRCLE, y))
    visu(y, :lines)
    visu(y, :line_segments)
    cat = loadasset("cat.obj")
    visu(cat)
end


function profileit()
    w = GLVisualize.current_screen()
    test(w)
    test(w)
    empty!(w)
    Profile.init()
    Profile.clear()
    for i=1:100
        test(w)
        empty!(w)
        println("#################################################")
    end
end
w = glscreen()
profileit()
using ProfileView
ProfileView.view()
