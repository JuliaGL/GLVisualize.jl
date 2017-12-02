#this is an example by https://github.com/musmo

using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors, GLWindow, ModernGL

description = """
Example showing a basic interactive setup for working inside the REPL/Atom/Jupyter.
It also shows how to not clear what has been drawn.
The camera is fixed, since otherwise it would smear the whole image.
"""

"""
Simulation function
"""
function solve_particles(pos_vel_s)
    dt = 1.5f0 # control simulation speed

    positions, velocity, s = pos_vel_s
    for i in eachindex(positions)
        velx = 0.0f0
        vely = 0.0f0
        posi = positions[i]
        for j in eachindex(positions)
            posj = positions[j]
            dx = posj[1] - posi[1]
            dy = posj[2] - posi[2]
            distsq = dx*dx + dy*dy + 1f0
            velx = velx - s[j]*dy/distsq
            vely = vely + s[j]*dx/distsq
        end
        positions[i] = Point2f0(posi[1] + dt*velx, posi[2] + dt*vely)
    end
    positions, velocity, s
end

"""
Clears the image of the window to `color`
"""
function clear_frame!(window, color = RGB(0.2,0.2,0.2))
    glClearColor(red(color), green(color), blue(color), 1)
    GLWindow.clear_all!(window)
end

"""
Resets the state of a window
"""
function reset!(window, color=RGB(0.2,0.2,0.2))
    clear_frame!(window, color)
    empty!(window) # removes all viewables that where added with `_view`
end

"""
This code should be executed only one time per julia session!!
If you accidantly close the window, you can call this again.
"""
function init(res = (800,800))
    # giving the window a transparent background color makes it transparent to
    # the previous frame. It's arguable, if that's really how things should be,
    # but that's how it currently works ;)
    window = glscreen(
        "vortex", resolution = res,
        color = RGB(0.2,0.2,0.2), clear = false
    )
    timesignal = Signal(0.0)
    speed = Signal(1/30)

    # this is equivalent to @async renderloop(window).
    # but now you can do other stuff before an image is rendered
    # the @async is used to make this non blocking for working in the REPL/Atom
    @async begin
        while isopen(window)
            # timesignal update value (here 0.01) doesn't matter for particle simulation, but controls the color update speed
            push!(timesignal, value(timesignal)+0.01)
            render_frame(window)
            swapbuffers(window)
            poll_glfw()
            yield()
            sleep(value(speed))
        end
        destroy!(window)
    end

    # this registers a callback whenever a keybutton is clicked.
    # We use Reactive signals, so every registered callback
    # returns a new signal with the returnvalue of that callback. Since we don't
    # use that signal, Reactive will try to garbage collect it, which is why we need
    # to call preserve on it.
    preserve(map(window.inputs[:keyboard_buttons]) do ksam
        key, scancode, action, mods = ksam
        if key == GLFW.KEY_S
            println("saving screenshot")
            screenshot(window, path="screenshot.jpg")
        end
        # make sure that this function doesn't return different types
        # for the if branch.
        # Reactive would try to convert them otherwise.
        nothing
    end)

    window, timesignal, speed
end


function main(window, timesignal)
    # get the resolution of the window
    res = widths(window)
    # use Float32 whenever possible to avoid conversions (GLVisualize can
    # convert to appropriate type most of the time, though)
    num = 1000 # change the number of particles!

    # particle initial conditions. Experiment with different ideas here.
    x = Float32[(res[1]/2.0) + (res[2]/3.5) * sin(i*2*pi/num) for i=0:num-1]
    y = Float32[(res[2]/2.0) + (res[2]/3.5) * cos(i*2*pi/num) for i=0:num-1]
    s = (-1 + 2*rand(Float32,num))

    # GeometryTypes.Point2f0 -> Point{2, Float32}
    start_position = Point2f0[Point2f0(xi,yi) for (xi,yi) in zip(x,y)]


    # Everything in GLVisualize gets animated with Reactive signals. So drawing a frame
    # and animating some graphic is decoupled.
    # for more infos, checkout Reactives documentation:
    # https://github.com/JuliaLang/Reactive.jl/blob/master/doc/index.md
    # In this case we use foldp to simulate the particles for every time step.
    # signature: foldp(function, startvalue, signals...), function will be called
    # with f(startvalue, signals...) every time timesignal updates.

    position_velocity = foldp(
        (v0, t) -> solve_particles(v0),
        (start_position, zeros(Float32, num), s),
        timesignal
    )
    # extract the position
    position = map(first, position_velocity)

    # create a color signal that changes over time
    # the color will update whenever timesignal updates
    color = map(timesignal) do t
        RGBA(1,1,(sin(t)+1.)/2., 0.6)
    end

    circle = Sphere(Point2f0(0), 1f0)

    # boundingbox is still a very expensive operation, so if you don't need it
    # you can simply set it to nothing.
    # The signature for all kind of particles is:
    # visualize((primitive, positions), keyword_arguments...)
    viewable = visualize(
        (circle, position),
        boundingbox = nothing,
        color = color
    )
    # reset is basically the antagonist of _view
    reset!(window) # when you reset the window here, you can call main multiple times

    # _view adds an (animated) viewable to the list of things that you want to see
    # in `window`
    _view(viewable, window, camera=:fixed_pixel)
end


#=
workflow in Julia REPL or you can also just evaluate parts in Atom:
include("simulation.jl")
window, t, speed = init()
main(window, t)
#redefine main/solve_particles
include("simulation.jl") # if you have the chan ges in the file
main() # call again! If you only changed solve_particles, you don't even have to call main again
push!(speed, 1/20) # this is fully interactive so you can, e.g. change the speed
=#

if !isdefined(:runtests)
    window, timesignal, speed = init()
else
    # if we get the window from the example recorder, change color!
    window.color = RGBA{Float32}(0,0,0,0)
    window.clear = true
end

main(window, timesignal)
# clean up window
