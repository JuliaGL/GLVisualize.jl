max_iterations = 256
imgx,imgy = 800,800
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
        if norm(z) > 2.0
            break
        end
        z = z * z + c
        i = t
    end
    heightfield[x,y] = -(i/512f0)
end

if !isdefined(:runtests) #
    using GLVisualize
    window = glscreen()
end
# visualize the heightfield as a surface
vis = visualize(heightfield, :surface)

# display it on the window
view(vis, window)

if !isdefined(:runtests)
    renderloop(w) # render!
end
