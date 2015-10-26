using GLVisualize
x, y = -1.5:0.5:500, -1:1:500
z = x + 1im * y

julia = zeros(Float32, size(z))

for i=1:50
    z = z ^ 2 - 0.70176 - 0.3842im
    julia += 1 / float(2 + i) * (z * conj(z) > 4)
end

w,r = glscreen()
view(visualize(julia))
r()
