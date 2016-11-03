using GLVisualize, GLAbstraction, Reactive, GeometryTypes, Colors, GLWindow

if !isdefined(:runtests)
    window = glscreen()
end

description = """
Demonstrating a UI for exploring the Koch snowflake.
"""


function spin(dir, α)
    x, y = dir
    Point(x*cos(α) - y*sin(α), x*sin(α) + y*cos(α))
end
function fractal_step!(
        a, b, depth, angles,
        result = Point2f0[a], levels = Float32[depth] # tmp too not allocate
    )
    depth == 0 && return result, levels, b
    N = length(angles)
    diff = (b - a)
    len = norm(diff) / (N - 1)
    nth_segment = normalize(diff)
    for n = 1:N
        b = a + spin(nth_segment * len, angles[n]) # rotate with current angle
        _, _, b = fractal_step!(a, b, depth-1, angles, result, levels) # recursion step
        if n < N
            push!(result, b)
            push!(levels, depth)
        end
        nth_segment = normalize(b - a)
        a = b
    end
    result, levels, b
end

function generate_fractal(angles, depth = 5)
    tmp = zeros(Point2f0, length(angles))
    angles = map(deg2rad, angles)
    result, levels, b = fractal_step!(Point2f0(0,0), Point2f0(300,0), round(Int, depth), angles)
    push!(result, b)
    push!(levels, depth)
    result, depth .- levels
end


controles = Dict(
    :angles => Vec4f0(0.0, 80.0, -140.0, 80.0),
    :colormap => map(RGBA{Float32}, colormap("Blues", 10)),
    :thickness => 0.5f0,
    :iterations => 6,
)

editarea, viewarea = x_partition(window.area, 30.0)
editscreen = Screen(
    window, area = editarea,
    color = RGBA{Float32}(0.1f0, 0.1f0, 0.1f0, 1f0),
    stroke = (1f0, RGBA{Float32}(0.13f0, 0.13f0, 0.13f0, 13f0))
)
viewscreen = Screen(
    window, area=viewarea,
    color = RGBA(0.1f0, 0.1f0, 0.1f0, 1f0)
)
GLVisualize.extract_edit_menu(controles, editscreen, true)


line_level = map(controles[:angles], controles[:iterations]) do angles, iter
    generate_fractal(angles, iter)
end

_view(visualize(
    map(first, line_level), :lines,
    thickness = controles[:thickness],
    color_map = controles[:colormap],
    intensity = map(last, line_level),
    color_norm = Vec2f0(0,10),
), viewscreen, camera=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
