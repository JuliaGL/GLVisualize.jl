# This example was inspired by this great blog post:
# https://cre8math.com/2015/10/04/creating-fractals/

using GLVisualize, GLAbstraction, Reactive, GeometryTypes, Colors, GLWindow
import GLVisualize: slider, mm, button, labeled_slider

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

const T = Float64
const P = Point{2, T}

function generate_fractal(angles, depth = 5)
    tmp = zeros(P, length(angles))
    angles = map(x-> (deg2rad(T(x[1])), T(x[2])), angles)
    result, levels, b = fractal_step!(P(0,0), P(300,0), round(Int, depth), angles)
    push!(result, b)
    push!(levels, depth)
    mini, maxi = extrema(result)
    w = 1 ./ maximum(maxi - mini)
    map!(result, result) do p
        1000 * (p - mini) .* w
    end
    # invert
    result, levels
end

iconsize = 5mm
textsize = 5mm


editarea, viewarea = x_partition_abs(window.area, round(Int, 12 * iconsize))
edit_screen = Screen(
    window, area = editarea,
    color = RGBA{Float32}(0.0f0, 0.0f0, 0.0f0, 1f0),
    stroke = (1f0, RGBA{Float32}(0.13f0, 0.13f0, 0.13f0, 1f0))
)
viewscreen = Screen(
    window, area = viewarea,
    color = RGBA(0.0f0, 0.0f0, 0.0f0, 1f0)
)


angles = ntuple(4) do i
    labeled_slider(0.0:1.0:360.0, edit_screen, text_scale = textsize, icon_size = iconsize, knob_scale = 3mm)
end

iterations_v, iterations_s = labeled_slider(1:11, edit_screen, text_scale = textsize, icon_size = iconsize, knob_scale = 3mm)

cmap_v, cmap_s = widget(
    map(RGBA{Float32}, colormap("Blues", 5)),
    edit_screen;
    area = (12 * iconsize, iconsize/3),
    knob_scale = 1.3mm,
)

thickness_v, thickness_s = widget(
    Signal(0.4f0), edit_screen,
    text_scale = textsize,
    range = 0f0:0.05f0:20f0
)

segments = Point2f0[
    (0.0, 0.0),
    (2 * iconsize, 0.0),
    (4 * iconsize, iconsize /  2),
    (6 * iconsize, iconsize / -2),
    (7 * iconsize, 0.0)
]

# we could restrict the movement of the points with the kw_arg clampto
# But I don't really feel like restricting the user here ;)
line_v, line_s = widget(segments, edit_screen, knob_scale = 1.5mm)

center_v, center_s = button("⛶", relative_scale = iconsize, edit_screen)

controls = Pair[
    "angle 1" => angles[1][1],
    "angle 2" => angles[2][1],
    "angle 3" => angles[3][1],
    "angle 4" => angles[4][1],
    "iterations" => iterations_v,
    "colormap" => cmap_v,
    "thickness" => thickness_v,
    "segment" => line_v,
    "center cam" => center_v
]


_view(visualize(
    controls,
    text_scale = textsize,
    width = 12iconsize
), edit_screen, camera = :fixed_pixel)

function to_anglelengths(angles, line)
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
v0 = to_anglelengths(Array{Tuple{Float32, Float32}}(4), value(line_s))

angle_vec1 = foldp(to_anglelengths, v0, line_s)

angle_s = map(last, angles)
anglevec2 = foldp(Array{Tuple{Float32, Float32}}(4), angle_s...) do angles, s...
    for i=1:4
        angles[i] = s[i], 1.0
    end
    angles
end
anglevec = merge(angle_vec1, anglevec2)

it1_points = map(anglevec) do angles
    generate_fractal(angles, 1)[1] ./ 100f0
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

s = preserve(map(center_s) do clicked
    clicked && center!(cam, AABB(value(line_pos)))
    nothing
end)

# center won't get executed before the first time the center button is clicked.
# we still want to start centered ;)
center!(cam, AABB(value(line_pos)))

if !isdefined(:runtests)
    renderloop(window)
    # clean up signals
    for (v, s) in angles
        close(s, false)
    end
    close(center_s, false)
    close(thickness_s, false)
    close(iterations_s, false)
    close(iterations_s, false)
end

# you can change angles directly like this:
# you need to start the renderloop asynchronously then though: @async renderloop(window)
# And then of course, don't clean up the signals before you are done
#push!(angles[3][2], 220f0)
