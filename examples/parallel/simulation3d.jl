if !isdefined(:runtests)
    addprocs(1)
end
srand(888)

description = """
Example showing off how to run GLVisualize in a different process
and visualize objects created on the main process.
"""


const workerid = workers()[]

using Images, GeometryTypes, GLVisualize, Reactive, GLWindow, Colors
using GLAbstraction

# Parallel helper function to launch our glvisualize operations on the process,
# on which we run GLVisualize
# I will move these functions to GLVisualize once this is tested better!
function p_setarg!(obj, key, value)
    @spawnat workerid begin
        GLAbstraction.set_arg!(fetch(obj), key, value)
        nothing
    end
end
function p_view(main, style=:default, cam=:perspective; kw_args...)
    @spawnat workerid begin
        obj = GLVisualize.visualize(main, style; kw_args...)
        GLVisualize._view(obj, camera=cam)
        obj
    end
end
function p_isopen()
    remotecall_fetch(workerid) do
        isempty(GLVisualize.get_screens()) && return false
        isopen(GLVisualize.current_screen())
    end
end
function p_empty!()
    remotecall(workerid) do
        empty!(GLVisualize.current_screen())
        nothing
    end
end


function solve_particles!(
        positions::AbstractVector{Point{N, T}}, s, dt::T = T(0.01)
    ) where {N, T}
    P = Point{N, T}
    # since Points are immutable, and we don't have comprehensions yet, there is
    # a map(index _> ..., ::Point) which we can use
    mask = map(i-> ifelse(isodd(i), -1, 1), P)
    @inbounds for i in eachindex(positions)
        vel = zero(P)
        posi = positions[i]
        for j in eachindex(positions)
            posj = positions[j]
            d = posj - posi
            distsq = dot(d, d) + T(1)
            vel = vel .+ (mask .* (s[j]*reverse(d)/distsq))
            any(x-> abs(x) > T(0.8), vel) && break # restrict velocity
        end
        positions[i] = posi .+ dt*vel
    end
    positions, s
end

"""
Generic implementation of initialising `N` dimensional points on an `N` dimensional
Sphere.
"""
function startpositions(N, radius::T, n) where T
    sphere = HyperSphere(Point{N, T}(0), T(radius))
    n = N == 3 ? floor(Int, sqrt(n)) : n # n must be n^2 for 3D Sphere
    decompose(Point{N, T}, sphere, n)
end

"""
The main simulation method, setting everything up and starting the simulation.
`T` controles what number type to use and defaults to Float32, but
code is written to support T == Float64 as well. So you can quickly try out both.
`N` changes the dimensionality between 2D and 3D
"""
function main(n, T=Float32, N=3)
    p_empty!() # empty window, so that we can call main multiple times

    positions = startpositions(N, T(0.5), n)
    # random factor for turbulence
    s = (-1 + 2 * rand(T, length(positions)))

    # boundingbox is an expensive operation, so if you don't need it
    # you can simply set it to nothing.
    # The signature for all kind of particles is:
    # visualize((primitive, positions), keyword_arguments...)
    # Note that we use p_view here, to visualize it on the worker process
    pointobj = p_view(
        (Circle(Point2f0(0), 0.01f0), positions),
        color = RGBA(1f0, 1f0, 1f0, 0.6f0),
        stroke_color = RGBA(1f0, 1f0, 1f0, 1f0),
        stroke_width = 0.001f0,
        boundingbox = nothing,
    )
    # maximum number of line segments we use to trace particle trajectory
    max_history = 80
    # To visualize a large number of lines with the same length, Matrix{Point} is
    # the way to go.
    lines = fill(Point{N, T}(NaN), max_history, length(positions))
    lines_color = fill(RGBA{Float32}(0, 0, 0, 0), max_history, length(positions))

    lines[1, :] = positions
    lines_color[1, :] = RGBA{Float32}(1, 1, 1, 0.2)

    linesobj = p_view(
        lines, :lines,
        color = vec(lines_color), # needs to be 1D right now, to lessen the amount of automatic conversions
        boundingbox = nothing,
        # this is an internal detail, need to figure out a better API
        # this makes the lines ignore NaN to seperate multiple lines
        startend = nothing,
        thickness = 0.5f0
    )
    t = 0.0
    dt = T(0.1)
    wait(linesobj) # wait until actually visualized
    while p_isopen()
        # lets print the times, to observe the slowing down when the velocity
        # cuttoff doesn't get reached as quickly anymore. Lucky for us that
        # GLVisualize runs in another process, so that the camera etc is still smooth
        tic()
        @time solve_particles!(positions, s, dt)

        # this seems a lot faster than circshift(lines, (1, 0))
        c = RGBA{Float32}(1, 1, (sin(t)+1.)/2., 0.2)
        for (i, p) in enumerate(positions)
            lines[:, i] = circshift(view(lines, :, i), 1)
            lines[1, i] = p
            lines_color[:, i] = circshift(view(lines_color, :, i), 1)
            lines_color[1, i] = c
        end

        p_setarg!(linesobj, :vertex, map(Point{N, Float32}, vec(lines)))
        p_setarg!(linesobj, :color, vec(lines_color))
        p_setarg!(pointobj, :position, map(Point{N, Float32}, positions))
        t += 0.05
        dt = T(toq())
    end
end

# start GLVisualize worker process
@spawnat workerid begin
    window = GLVisualize.glscreen(color = RGBA(0f0, 0f0, 0f0, 1f0))
    @async GLWindow.renderloop(window)
    nothing
end
# start main
main(10_000)

# clean up process
remotecall_fetch(workerid) do
    GLVisualize.cleanup()
    return
end
nothing
