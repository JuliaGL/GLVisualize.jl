#this is an example by https://github.com/musmo

using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors, GLWindow, ModernGL


"""
Simulation function
"""
function solve_particles(pos_vel_s)
    dt = 1.0f0

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
function clear_frame!(window, color=RGB(0.2,0.2,0.2))
    glClearColor(red(color), green(color), blue(color), 1)
    GLWindow.clear_all!(window)
end

"""
Resets the state of a window
"""
function reset!(window, color=RGB(0.2,0.2,0.2))
    clear_frame!(window, color)
    empty!(window.renderlist) # removes all viewables that where added with `view`
end

"""
This code should be executed only one time per julia session!!
If you accidantly close the window, you can call this again.
"""
function init(res=(800,600))
    # giving the window a transparent background color makes it transparent to
    # the previous frame. It's arguable, if that's really how things should be,
    # but that's how it currently works ;)
    window = glscreen("vortex", resolution=res, background=RGBA(0,0,0,0))
    timesignal = Signal(0.0)
    speed = Signal(1/30)

    @async while isopen(window)
        push!(timesignal, value(timesignal)+0.01) # value doesn't matter
        render_frame(window)
        sleep(value(speed))
    end

    preserve(map(window.inputs[:keyboard_buttons]) do kam
            key, action, mods = kam
            if key == GLFW.KEY_S
                println("saving screenshot")
                screenshot(window, path="screenshot.jpg")
            end
        end
    )

    window, timesignal, speed
end


function main(window, timesignal)
    res = widths(window)
    const num = 1000

    x = Float32[(res[1]/2.0) + (res[2]/3.5) * sin(i*2*pi/num) for i=0:num-1]
    y = Float32[(res[2]/2.0) + (res[2]/3.5) * cos(i*2*pi/num) for i=0:num-1]
    s = (-1 + 2*rand(Float32,num))

    start_position = Point2f0[Point2f0(xi,yi) for (xi,yi) in zip(x,y)]
    # foldp calls solve_particles with the startvalue, v0, and the argument, timesignal, every time
    # time signal updates. https://github.com/JuliaLang/Reactive.jl/blob/master/doc/index.md
    # signature: foldp(function, startvalue, signals...), function will be called
    # with f(starvalue, signals...)
    position_velocity = foldp((v0,t) -> solve_particles(v0), (start_position, zeros(Float32,num), s), timesignal)


    # create a color signal that changes over time
    color = map(timesignal) do t
        RGBA(1,1,(sin(t)+1.)/2., 0.05)
    end

    circle = HyperSphere(Point2f0(0), 0.7f0)

    # boundingbox is still a very expensive operation, so if you don't need it
    # you can simply set it to nothing.
    vis = visualize(
        (circle, map(first, position_velocity)),
        boundingbox=nothing,
        color=color
    )
    reset!(window) # when you reset the window here, you can call main multiple times
    view(vis, window, camera=:fixed_pixel)
end


#workflow in Julia REPL or you can also just evaluate parts in Atom:
#=
include("simulation.jl")
window, t, speed = init()
main(window, t)
#redefine main/solve_particles
include("simulation.jl") # if you have the changes in the file
main() # call again! If you only changed solve_particles, you don't even have to call main again
push!(speed, 1/20) # change speed
=#
# this is needed, because GLVisualizes records these examples automatically,
# in this case, the recording code supplies window and timesignal
if !isdefined(:runtests)
    window, timesignal, speed = init()
end
main(window, timesignal)
# when this gets created by runtests, the window won't have been created via init
# so we need to change the color here
window.color = RGBA(0,0,0,0)
