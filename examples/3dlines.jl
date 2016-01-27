if !isdefined(:runtests)
    using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive
    n = 400 # The number of points per line
    nloops = 20
else
    n = 20
    nloops = 5
end
# The scalar parameter for each line
TL = linspace(-2f0 * pi, 2f0 * pi, n)
# We create a list of positions and connections, each describing a line.
# We will collapse them in one array before plotting.
xyz         = Point3f0[]
s           = RGBA{Float32}[]

# The index of the current point in the total amount of points
base_colors1 = distinguishable_colors(nloops, RGB{Float64}(1,0,0))
base_colors2 = distinguishable_colors(nloops, RGB{Float64}(1,1,0))
# Create each line one after the other in a loop
for i=1:nloops
    append!(xyz, [Point3f0(sin(t), cos((2 + .02 * i) * t), cos((3 + .03 * i) * t)) for t in TL])
    unique_colors = base_colors1[i]
    hsv = HSV(unique_colors)
    color_palette = map(x->RGBA{Float32}(x, 1.0), sequential_palette(hsv.h, n, s=hsv.s))
    append!(s, color_palette)
end

w = glscreen()
buff = GLBuffer(s)
view(visualize(Signal(xyz), :lines, color=buff), method=:perspective)


if !isdefined(:runtests)
    renderloop(w)
end
