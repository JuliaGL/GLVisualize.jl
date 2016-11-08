using GLVisualize, GLAbstraction

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end

description = """
Drawing the Juliaset as a surface plot.
"""

function juliadata(max_iterations, imgx, imgy)
    scalex, scaley = 4.0/imgx, 4.0/imgy

    # initialize our Float32 heightfield
    heightfield = zeros(Float32, imgx, imgy)

    # do julia set magic!
    for x=1:imgx, y=1:imgy
        cy = y * scaley - 2.0
        cx = x * scalex - 2.0
        z = Complex(cx, cy)
        c = Complex(-0.4, 0.6)
        i = 0
        for t in 0:max_iterations
            norm(z) > 2.0 && break
            z = z * z + c
            i = t
        end
        heightfield[x,y] = -(i/512f0)
    end
    heightfield
end


rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

heightfield = juliadata(256, 250, 250)

# visualize the heightfield as a surface
vis = visualize(
    heightfield, :surface,
    model = rotation
)

# display it on the window
_view(vis, window)


if !isdefined(:runtests)
    renderloop(window) # render!
end
