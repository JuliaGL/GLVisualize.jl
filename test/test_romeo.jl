using GLVisualize, GLFW, GLAbstraction, Reactive, ModernGL, GLWindow, Color


# From behaviour, we understand that loading GLFW opens the window

function clear!(x::Vector{RenderObject})
    while !isempty(x)
        value = pop!(x)
        delete!(value)
    end
end


function dropequal(a::Signal)
    is_equal = foldl((false, a.value), a) do v0, v1
        (v0[2] == v1, v1)
    end
    dropwhen(lift(first, is_equal), a.value, a)
end

function eval_visualize(source::AbstractString, _, visualize_screen, edit_screen)
    expr = parse(strip(source), raise=false)
    val = "not found"
    try
        val = eval(Main, expr)
    catch e
        return nothing
    end
    if applicable(visualize, val)
        clear!(visualize_screen.renderlist)
        clear!(edit_screen.renderlist)
        obj     = visualize(val, screen=visualize_screen)

        push!(visualize_screen.renderlist, obj)
    end
    nothing
end

function init_romeo()
    sourcecode_area = lift(GLVisualize.ROOT_SCREEN.area) do x
    	Rectangle(0, 0, div(x.w, 7)*3, x.h)
    end
    visualize_area = lift(GLVisualize.ROOT_SCREEN.area) do x
        Rectangle(div(x.w,7)*3, 0, div(x.w, 7)*3, x.h)
    end
    search_area = lift(visualize_area) do x
        Rectangle(x.x, x.y, x.w, div(x.h,10))
    end
    edit_area = lift(GLVisualize.ROOT_SCREEN.area) do x
    	Rectangle(div(x.w, 7)*6, 0, div(x.w, 7), x.h)
    end


    sourcecode_screen   = Screen(GLVisualize.ROOT_SCREEN, area=sourcecode_area)
    visualize_screen    = Screen(GLVisualize.ROOT_SCREEN, area=visualize_area)
    search_screen       = Screen(visualize_screen,        area=search_area)
    edit_screen         = Screen(GLVisualize.ROOT_SCREEN, area=edit_area)

    w_height = lift(GLVisualize.ROOT_SCREEN.area) do x
    	x.h
    end
    source_offset = lift(w_height) do x
        translationmatrix(Vec3(30,x-30,0))
    end
    w_height_search = lift(search_screen.area) do x
        x.h
    end
    search_offset = lift(w_height_search) do x
        translationmatrix(Vec3(30,x-30,0))
    end

    #const sourcecode  = visualize("barplot = Float32[(sin(i/10f0) + cos(j/2f0))/4f0 \n for i=1:10, j=1:10]\n", model=source_offset, screen=sourcecode_screen)
    barplot            = visualize(Float32[(sin(i/10f0) + cos(j/2f0))/4f0 + 1f0 for i=1:10, j=1:10], screen=visualize_screen)
    #search            = visualize("barplot\n", model=search_offset, color=rgba(0.9,0,0.2,1), screen=search_screen)

    push!(visualize_screen.renderlist, barplot)
    glClearColor(0,0,0,0)
end

init_romeo()

renderloop()

