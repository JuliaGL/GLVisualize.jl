using GLVisualize, GLAbstraction, Reactive, GeometryTypes, Colors, GLWindow
import GLVisualize: slider, mm, button

if !isdefined(:runtests)
    window = glscreen()
end

description = """
Demonstrating a UI for exploring the Koch snowflake.
"""

function spin(dir, α, len)
    x, y = dir
    Point(x*cos(α) - y*sin(α), x*sin(α) + y*cos(α)) * len
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
        b = a + spin(nth_segment * len, angles[n]...) # rotate with current angle
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
    angles = map(x-> (deg2rad(x[1]), x[2]), angles)
    result, levels, b = fractal_step!(Point2f0(0,0), Point2f0(300,0), round(Int, depth), angles)
    push!(result, b)
    push!(levels, depth)
    result, depth .- levels
end

editarea, viewarea = x_partition(window.area, 30.0)
edit_screen = Screen(
    window, area = editarea,
    color = RGBA{Float32}(0.1f0, 0.1f0, 0.1f0, 1f0),
    stroke = (1f0, RGBA{Float32}(0.13f0, 0.13f0, 0.13f0, 13f0))
)
viewscreen = Screen(
    window, area = viewarea,
    color = RGBA(0.1f0, 0.1f0, 0.1f0, 1f0)
)
iconsize = 25
kw_args = [
    (:slider_length, 6 * iconsize),
    (:icon_size, Signal(iconsize)),
]
range = 0.0f0:0.5:360f0

a_angle_v, a_angle_s = slider(range, edit_screen; kw_args...)
b_angle_v, b_angle_s = slider(range, edit_screen; kw_args...)
c_angle_v, c_angle_s = slider(range, edit_screen; kw_args...)
d_angle_v, d_angle_s = slider(range, edit_screen; kw_args...)

minimum(value(boundingbox(d_angle_v)))

iterations_v, iterations_s = slider(1:11, edit_screen; kw_args...)

cmap_v, cmap_s = widget(
    map(RGBA{Float32}, colormap("Blues", 5)),
    edit_screen;
    area = (7 * iconsize, iconsize/2),
    knob_scale = 4f0,
)

thickness_v, thickness_s = widget(
    Signal(0.4f0), edit_screen,
    text_scale = Vec2f0(0.5),
    range = 0f0:0.05f0:20f0
)

segments = Point2f0[
    (0.0, 0.0),
    (2 * iconsize, 0.0),
    (4 * iconsize, iconsize),
    (6 * iconsize, -iconsize),
    (8 * iconsize, 0.0)
]

line_v, line_s = widget(segments, edit_screen)

center_v, center_s = button("⛶", edit_screen)

controles = [
    "angle 1" => a_angle_v,
    "angle 2" => b_angle_v,
    "angle 3" => c_angle_v,
    "angle 4" => d_angle_v,
    "iterations" => iterations_v,
    "colormap" => cmap_v,
    "thickness" => thickness_v,
    "segment" => line_v,
    "center cam" => center_v
]

_view(
    visualize(controles, text_scale = 3mm),
    edit_screen, camera = :fixed_pixel
)
angle_vec1 = foldp(Array(Tuple{Float32, Float32}, 4), line_s) do angles, line
    diff0 = Point2f0(1, 0)
    v1 = first(line)
    maxlen = 0
    for (i, v2) in enumerate(line[2:end])
        diff1 = v2 - v1
        len = norm(diff1)
        diff1 = normalize(diff1)
        maxlen = max(len, maxlen)

        d = dot(diff0, diff1)
        det = cross(diff0, diff1)

        angles[i] = (atan2(det, d), len)
        v1 = v2; diff0 = diff1
    end
    for (i, al) in enumerate(angles)
        angles[i] = (rad2deg(al[1]), al[2] / maxlen)
    end
    angles
end

angle_s = (a_angle_s, b_angle_s, c_angle_s, d_angle_s)
anglevec2 = foldp(Array(Tuple{Float32, Float32}, 4), angle_s...) do angles, s...
    for i=1:4
        angles[i] = s[i], 1.0
    end
    angles
end
anglevec = merge(angle_vec1, anglevec2)

it1_points = map(anglevec) do angles
    generate_fractal(angles, 1)[1] ./ 7f0
end

line_level = map(anglevec, iterations_s) do angles, iter
    generate_fractal(angles, iter)
end
line_pos = map(first, line_level)
_view(visualize(
    line_pos, :lines,
    thickness = thickness_s,
    color_map = cmap_s,
    color_norm = map(i-> Vec2f0(0, i), iterations_s),
    intensity = map(last, line_level),
    boundingbox = nothing
), viewscreen, camera = :orthographic_pixel)

_view(visualize(
    it1_points, :lines, model = translationmatrix(Vec3f0(20, 20, 0)),
    thickness = 2f0, color = RGBA(1f0, 1f0, 1f0, 1f0)
), viewscreen, camera = :fixed_pixel)

const cam = viewscreen.cameras[:orthographic_pixel]
s = preserve(map(center_s, init = nothing) do clicked
    clicked && center!(cam, AABB{Float32}(value(line_pos)))
    nothing
end)

if !isdefined(:runtests)
    renderloop(window)
end
