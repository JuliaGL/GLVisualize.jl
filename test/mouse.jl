using GLVisualize, GLAbstraction, GeometryTypes, Reactive, Colors, GLFW
function circlescale(v0, pressed)
    scale = v0
    if isempty(pressed)
        for i in eachindex(scale)
            scale[i] = Vec2f0(20)
        end
    else
        ls = linspace(1.0, 2.0, length(scale))
        for i in eachindex(scale)
            scale[i] = Vec2f0(20*ls[i])
        end
    end
    scale
end
mpos(x) = translationmatrix(Vec3f0(x, 0))
function to_color(button)
    if button == GLFW.MOUSE_BUTTON_LEFT
        return GLVisualize.default(RGBA)
    elseif button == GLFW.MOUSE_BUTTON_MIDDLE
        return RGBA{Float32}(0.9,0.1, 0.3, 1.0)
    elseif button == GLFW.MOUSE_BUTTON_MIDDLE
        return RGBA{Float32}(0.9,0.1, 0.9, 1.0)
    end
    RGBA{Float32}(0.6,0.6,0.6,1.0)
end

function mouse_color(pressed)
    if isempty(pressed)
        return RGBA{Float32}(0,0,0,0.8)
    else
        return to_color(first(pressed))
    end
end

function add_mouse(window)
    N = 2
    points = fill(Point2f0(0), N)

    @materialize mouseposition, mouse_buttons_pressed = window.inputs

    model_matrix = map(mpos, mouseposition)

    scales0 = fill(Vec2f0(20), N)

    scale = foldp(circlescale, scales0, mouse_buttons_pressed)
    color = map(mouse_color, mouse_buttons_pressed)

    _view(visualize(
        (Circle(Point2f0(0), 20f0), points),
        color=RGBA{Float32}(0,0,0,0), stroke_width=2f0,
        stroke_color=color, scale=scale,
        model=model_matrix
    ), window, camera=:fixed_pixel)

end
