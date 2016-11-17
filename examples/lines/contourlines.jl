using Contour, GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0.0, 1.0, 360))
end

description = """
This example uses the Contour.jl library to generate
contour lines from an heightfield.
"""

# create a rotation from the time signal
rotation = map(timesignal) do t
    rotationmatrix_z(Float32(t*2pi)) # -> 4x4 Float32 rotation matrix
end

xrange = -5f0:0.02f0:5f0
yrange = -5f0:0.02f0:5f0

z = Float32[sin(1.3*x)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x) for x in xrange, y in yrange]
mini = minimum(z)
maxi = maximum(z)
color_ramp = map(x->RGBA{Float32}(x, 1.0), colormap("Blues"))
points = Point3f0[]
colors = RGBA{Float32}[]

for h in mini:0.2f0:maxi
    c = Contour.contour(xrange, yrange, z, h)
    for elem in c.lines
        c = color_lookup(color_ramp, h, mini, maxi)
        for p in elem.vertices
            push!(points, Point3f0(p[1], p[2], h))
            push!(colors, c)
        end
        # we can seperate colors with NaN's (might change soon!)
        push!(points, Point3f0(NaN32))
        push!(colors, c)
    end
end

line_renderable = visualize(
    points, :lines,
    color = colors,
    model = rotation
)
_view(line_renderable, window, camera=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
