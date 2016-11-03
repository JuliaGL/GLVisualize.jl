addprocs(1)
@everywhere using GLVisualize, GLAbstraction, Reactive, GeometryTypes, Colors

w = glscreen(color = RGBA(0.1f0, 0.1f0, 0.1f0, 1f0))
@async renderloop(w)

@everywhere function displace(a, dir, normal, segment)
    x, y = segment
    a + (dir * x) + (normal * y)
end
@everywhere function fractal_step!(segments, idx, segment)
    a, b = segments[Face(idx, idx+1)]
    dir = b - a
    normal = Point2(-dir[2], dir[1])
    iter = (displace(a, dir, normal, segment[i + 1]) for i=1:3)
    splice!(segments, (idx + 1):idx, iter)
    # if idx + 2 <= length(segments)
    #     a = segments[idx % 4]
    # end
    segments
end
@everywhere function generate_fractal(segment, iterations = 5, start = [segment ; first(segment)])
    segment = segment ./ 100.0
    for iters=1:iterations
        n = length(start) - 2
        for i=0:n
            fractal_step!(start, i*4 + 1, segment)
        end
    end
    start
end

segment = Point2f0[(0.0, 0.0), (25.0, 0.0), (50.0, 50.0), (75.0, 0.0), (100.0, 0.0)]
vis, sig = GLVisualize.edit_line(
    segment, Vec2f0(1, 1), (0, 200), w
)
# move a bit to the top
set_arg!(vis, :model, translationmatrix(Vec3f0(10, 10, 0)))
_view(vis, camera=:fixed_pixel)


segment_s = map(sig) do s
    GLAbstraction.gpu_data(vis.children[1][:vertex])
end
iters = Signal(5)
init = Signal([segment ; first(segment)])
const channel = Channel{Vector{Point2f0}}(1)
v0 = Point2f0[0]
put!(channel, v0)
lines = foldp(v0, segment_s, iters, init) do v0, segment, i, start
    if isready(channel)
        points = take!(channel)
        task = @async put!(channel, remotecall_fetch(generate_fractal, 2, segment, i, start))
        return points
    end
    v0
end
x = visualize(
    lines, :lines,
    color = RGBA(1f0, 1f0, 1f0, 1.0f0),
    thickness = 0.5f0
)
_view(x)
set_arg!(x, :thickness, 0.5f0)
