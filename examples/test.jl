using GLVisualize, GeometryTypes
w,r = glscreen()
#cubecamera(w)

m = 512
x, y = linspace(-2.,2.,m), linspace(-1.,1.,m+1)
xx,yy = x.+0.*y',0.*x.+y'

k=101
α=exp(-π*k/50im)

sqrtx2(z::Complex) = sqrt(z-1)*sqrt(z+1)
map_kernel(x, y, α) = imag((x+im*y + sqrtx2(x+im*y)))

heightfield = zeros(Intensity{1,Float32}, size(xx))
for ei in eachindex(heightfield)
	x,y = xx[ei], yy[ei]
	heightfield[ei] = map_kernel(x, y, α)
end

view(visualize(heightfield), method=:orthographic_pixel)
r()

