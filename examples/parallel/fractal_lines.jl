using GLVisualize, GLAbstraction, Reactive, GeometryTypes, Colors, GLWindow

if !isdefined(:runtests)
    window = glscreen()
    addprocs(1)
end

description = """
Example showing off how to run computations in a different process and then
visualizing them.
"""

const workerid = workers()[]


@everywhere begin
    using GeometryTypes
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
end


editarea, viewarea = x_partition(window.area, 30.0)
editscreen = Screen(
    window, area = editarea,
    color = RGBA{Float32}(0.1f0, 0.1f0, 0.1f0, 1f0),
    stroke = (1f0, RGBA{Float32}(0.13f0, 0.13f0, 0.13f0, 13f0))
)
viewscreen = Screen(window, area=viewarea, color = RGBA(0.1f0, 0.1f0, 0.1f0, 1f0))

controls = [
    :angles => Vec4f0(0.0, 80.0, -140.0, 80.0),
    :colormap => map(RGBA{Float32}, colormap("Blues", 10)),
    :thickness => 0.5f0,
    :iterations => 6,
]

menu, controls = GLVisualize.extract_edit_menu(controls, editscreen, true)
_view(menu, editscreen, camera = :fixed_pixel)


const channel2 = Channel{Tuple{Vector{Point2f0}, Vector{Float32}}}(1)
v0 = (Point2f0[0,0,0,0], Float32[0,0,0,0])
put!(channel2, v0)
line_level = foldp(v0, controls[:angles], controls[:iterations]) do v0, angles, iter
    if isready(channel2)
        points = take!(channel2)
        task = @async put!(
            channel2,
            remotecall_fetch(generate_fractal, workerid, angles, iter)
        )
        return points
    end
    v0
end

_view(visualize(
    map(first, line_level), :lines,
    intensity = map(last, line_level),
    thickness = controls[:thickness],
    color_map = controls[:colormap],
    color_norm = Vec2f0(0,10),
), viewscreen, camera=:orthographic_pixel)


if !isdefined(:runtests)
    renderloop(window)
end
