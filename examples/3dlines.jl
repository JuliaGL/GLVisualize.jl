if !isdefined(:runtests) # We use the examples to generate docs and tests
    using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive
    time = bounce(linspace(0.0, 1.0, 360))
    window = glscreen()
end

n = 400 # The number of points per line
nloops = 20 # The number of loops
# The scalar parameter for each line
TL = linspace(-2f0 * pi, 2f0 * pi, n)
# We create a list of positions and connections, each describing a line.
# We will collapse them in one array before plotting.
xyz    = Point3f0[]
colors = RGBA{Float32}[]

# creates some distinguishable colors from which we can sample for each line
base_colors1 = distinguishable_colors(nloops, RGB{Float64}(1,0,0))
# Create each line one after the other in a loop
for i=1:nloops
    append!(xyz, [Point3f0(sin(t), cos((2 + .02 * i) * t), cos((3 + .03 * i) * t)) for t in TL])
    unique_colors = base_colors1[i]
    hsv = HSV(unique_colors)
    color_palette = map(x->RGBA{Float32}(x, 1.0), sequential_palette(hsv.h, n, s=hsv.s))
    append!(colors, color_palette)
end

# map comes from Reactive.jl and allows you to map any Signal to another.
# In this case we create a rotation matrix from the time signal.

rotation = map(time) do t
    rotationmatrix_z(Float32(t*2pi)) # -> 4x4 Float32 rotation matrix
end
view(visualize(xyz, :lines, color=colors, model=rotation), method=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
