using Contour, GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO
xrange = -5f0:0.02f0:5f0
yrange = -5f0:0.02f0:5f0

z = Float32[sin(1.3*x)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x) for x in xrange, y in yrange]
mini = minimum(z)
maxi = maximum(z)
w = glscreen()
colormap = map(x->RGBA{Float32}(x, 1.0), colormap("Blues"))
trans = Vec3f0(0)
toindex(val, mini, maxi, len) = floor(Int, (((val-mini)/(maxi-mini))*(length(colormap)-1)))+1
for h in mini:0.2f0:maxi
    c = contour(xrange, yrange, z, h)
    for elem in c.lines
        points = map(elem.vertices) do p
            Point3f0(p, h)
        end
        view(visualize(
            points, :lines,
            color=colormap[toindex(h, mini, maxi, length(colormap))]
        ), method=:perspective)
        view(visualize(elem.vertices, :lines, model=translationmatrix(Vec3f0(0,11,0))), method=:perspective)
    end
end
trans += Vec3f0(11,0,0)
view(visualize(
    z, :surface, grid_start=(-5,-5), grid_size=(10, 10),
    model=translationmatrix(trans)
))

trans += Vec3f0(0,11,0)

view(visualize(
    reinterpret(Intensity{1,Float32}, z), grid_start=(-5,-5), grid_size=(10, 10),
    model=translationmatrix(trans)
), method=:perspective)
frames = []
while isopen(w)
    GLWindow.renderloop_inner(w)
    push!(frames, GLWindow.screenbuffer(w))
end
name = "contour"
root_path = joinpath(homedir(), "gl_videos")
for (i,elem) in enumerate(frames)
    save(joinpath(root_path, "$name$i.png"), elem)
end
