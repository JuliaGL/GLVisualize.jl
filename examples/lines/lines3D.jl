using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive

if !isdefined(:runtests) # We use the examples to generate docs and tests
    window = glscreen()
    timesignal = bounce(linspace(0.0, 1.0, 360))
end

description = """
Coloured 3D line example.
"""

n = 400 # The number of points per line
nloops = 20 # The number of loops
# The scalar parameter for each line
TL = linspace(-2f0 * pi, 2f0 * pi, n)
# We create a list of positions and connections, each describing a line.
# We will collapse them in one array before plotting.
xyz = Point3f0[]
intensities = Float32[]


# Create each line one after the other in a loop
for i = 1:nloops
    append!(xyz, [Point3f0(sin(t), cos((2 + .02 * i) * t), cos((3 + .03 * i) * t)) for t in TL])
    append!(intensities, fill(i, length(TL)))
end

# map comes from Reactive.jl and allows you to map any Signal to another.
# In this case we create a rotation matrix from the timesignal signal.

rotation = map(timesignal) do t
    rotationmatrix_z(Float32(t*2pi)) # -> 4x4 Float32 rotation matrix
end

# creates a color map from which we can sample for each line
# and add some transparency
cmap = map(x-> RGBA{Float32}(x, 0.4), colormap("Blues", nloops))

lines3d = visualize(
    xyz, :lines,
    intensity = intensities,
    color_map = cmap,
    color_norm = Vec2f0(0, nloops), # normalize intensities. Lookup in cmap will be between 0-1
    model = rotation
)

_view(lines3d, window, camera=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
