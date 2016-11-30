using Images, GeometryTypes, GLVisualize, Reactive, GLWindow, Colors
using GLAbstraction, GLFW
import GLAbstraction: singlepressed, imagespace
import GLVisualize: moving_average

if !isdefined(:runtests)
    window = glscreen()
end

description = """
Drawing lines and then adding symmetrie to them.
"""

window.color = RGBA(0f0, 0f0, 0f0, 1f0)

const linebuffer = Signal(fill(Point2f0(NaN), 4))
const middle = Point2f0(widths(window)) / 2
const symmetries = 18
const unsmoothed = copy(value(linebuffer))


function angle_between(a, b)
    a = normalize(a)
    b = normalize(b)
    atan2(cross(a, b), dot(a, b))
end


symmetry_lines = foldp(Point2f0[], linebuffer) do v0, lines
    resize!(v0, symmetries * length(lines))
    i = 1;
    for fi = linspace(0, 2pi, symmetries)
        for point in lines
            diff = middle - point
            radius = norm(diff)
            _fi = (fi + angle_between(diff, Point2f0(0, 1))) % 2pi
            v0[i] = radius * Point2f0(
                sin(_fi + pi),
                cos(_fi + pi)
            ) + middle
            i += 1
        end
    end
    v0
end

const lineobj = visualize(
    symmetry_lines, :lines,
    color = RGBA(0.8f0, 0.8f0, 0.8f0, 1f0),
    thickness = 1.5f0,
    boundingbox = AABB{Float32}(value(window.area)) # boundingbox for center!
)
_view(lineobj, window, camera = :orthographic_pixel)

@materialize mouseposition, mouse_buttons_pressed, mouseinside, buttons_pressed = window.inputs

camera = window.cameras[:orthographic_pixel]
const history = Point2f0[]
s = map(mouseposition, mouse_buttons_pressed, init = nothing) do mp, mbp
    l0 = value(linebuffer)
    if singlepressed(mbp, GLFW.MOUSE_BUTTON_LEFT) && value(mouseinside) && isempty(value(buttons_pressed))
        p = imagespace(mp, camera)
        keep, p = moving_average(p, 1.5f0, history)
        if keep
            push!(linebuffer, push!(l0, p))
        end
    else
        if !isnan(last(l0)) # only push one NaN to seperate
            empty!(history) # reset
            push!(linebuffer, push!(l0, Point2f0(NaN)))
        end
    end
    nothing
end
# preserve signals, so that it doesn't get garbage collected.
preserve(s)
# we need to define init, because otherwise it will be initialised by calling
# the function one time, which

if !isdefined(:runtests)
    renderloop(window)
end
