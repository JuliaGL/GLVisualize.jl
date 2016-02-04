max_iterations = 256

imgx = 800
imgy = 800

scalex = 4.0 / imgx
scaley = 4.0 / imgy

heightfield = zeros(Float32, imgx, imgy)

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

using GLVisualize
w = glscreen()

view(visualize(heightfield, :surface))

renderloop(w)