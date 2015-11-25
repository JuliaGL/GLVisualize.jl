using GLAbstraction, Colors, Images
# The number of points per line
N = 300

# The scalar parameter for each line
TL = linspace(-2f0 * pi, 2f0 * pi, N)

# We create a list of positions and connections, each describing a line.
# We will collapse them in one array before plotting.
xyz         = Point3f0[]
s           = RGBA{Float32}[]

# The index of the current point in the total amount of points
nloops = 50
base_colors1 = distinguishable_colors(nloops, RGB{Float64}(1,0,0))
base_colors2 = distinguishable_colors(nloops, RGB{Float64}(1,1,0))
# Create each line one after the other in a loop
for i=1:nloops
    append!(xyz, [Point3f0(sin(t), cos((2 + .02 * i) * t), cos((3 + .02 * i) * t)) for t in TL])
    unique_colors = base_colors1[i]
    hsv = HSV(unique_colors)
    color_palette = map(x->RGBA{Float32}(x, 1.0), sequential_palette(hsv.h, N, s=hsv.s))
    append!(s, color_palette)
end

using GLVisualize, Reactive
w, r = glscreen()
buff = GLBuffer(s)
view(visualize(Signal(xyz), :lines, color=buff), method=:perspective)
r()