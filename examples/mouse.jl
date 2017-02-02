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

function transmat(x, pressed)
    c = !isempty(pressed)
    translationmatrix(Vec3f0(x, 0)) * scalematrix(Vec3f0(c ? 0.7 : 1.0))
end


function add_mouse(window)
    @materialize mouseposition, mouse_buttons_pressed = window.inputs
    model_matrix = map(transmat, mouseposition, mouse_buttons_pressed)
    cursor = map(RGBA{N0f8}, loadasset("cursor.png"))
    w,h = size(cursor)
    ratio = Float32(w/h)
    w, h = ratio*15f0, 15f0
    _view(visualize(
        cursor,
        model=model_matrix,
        primitive=SimpleRectangle(-1f0, -(h+1f0), w, h)
    ), window, camera=:fixed_pixel)
end
