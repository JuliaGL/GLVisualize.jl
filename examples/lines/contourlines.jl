using Contour, GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0.0, 1.0, 360))
end
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

for h in mini:0.2f0:maxi
    c = contour(xrange, yrange, z, h)
    for elem in c.lines
        points = map(elem.vertices) do p
            Point3f0(p, h)
        end
        line_renderable = visualize(
            points, :lines,
            color=color_lookup(color_ramp, h, mini, maxi),
            model=rotation
        )
        _view(line_renderable, window, camera=:perspective)
    end
end

if !isdefined(:runtests)
    renderloop(window)
end
