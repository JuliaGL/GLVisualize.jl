meshgrid(v::AbstractVector) = meshgrid(v, v)

function meshgrid{T}(vx::AbstractVector{T}, vy::AbstractVector{T})
    m, n = length(vy), length(vx)
    vx = reshape(vx, 1, n)
    vy = reshape(vy, m, 1)
    (repmat(vx, m, 1), repmat(vy, 1, n))
end

function meshgrid{T}(vx::AbstractVector{T}, vy::AbstractVector{T},
                     vz::AbstractVector{T})
    m, n, o = length(vy), length(vx), length(vz)
    vx = reshape(vx, 1, n, 1)
    vy = reshape(vy, m, 1, 1)
    vz = reshape(vz, 1, 1, o)
    om = ones(Int, m)
    on = ones(Int, n)
    oo = ones(Int, o)
    (vx[om, :, oo], vy[:, on, oo], vz[om, on, :])
end

# Calculate the Julia set on a grid
x,y = meshgrid(-1.5f0:0.5f0:500f0, -1f0:1f0:500f0)
x *= 1im
y *= 1im
println(size(x))
println(size(y))
z = x + 1im * y

const julia = zeros(Float32, size(z))

for i=1:50
	for i in eachindex(julia)
    	z[i] = (z[i]^2) - 0.70176 - 0.3842im
    	x = (z[i] * (real(conj(z[i])) > 4))
    	julia[i] += real(1f0 / (2f0 + i) * x)
    end
end
maxval = maximum(julia)
map!(julia ) do val 
	val / maxval
end
using GLVisualize
w,r =glscreen()
# Display it
view(visualize(julia))

r()
