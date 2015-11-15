# Calculate the Julia set on a grid
x = [Float32(i)*im for i=-1.5:0.5:500]
y = [Float32(i)*im for i=-1:1:500]
println(size(x))
println(size(y))
z = x + 1im * y

julia = zeros(Float32, size(z))

for i=1:50
    z = z^2 - 0.70176 - 0.3842im
    julia += 1 / 2f0 + i) * (z * conj(z) > 4)
end

# Display it
view(visualize(julia))

# A view into the "Canyon"
view(65, 27, 322, [30., -13.7,  136])
show()

