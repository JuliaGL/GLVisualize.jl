function plot(m)
    srand(17)
    x = Context[visualize(rand(Point2f0, 4)*150, :lines) for _=1:15]
    view(visualize(x), method=:orthographic_pixel)
end
function plot2()
    points = [Point2f0(offset, sin(offset/80)*100) for offset=linspace(0,1000*50, 4*3*50)]
    indices = Signal(UnitRange{Int}[1:4, 5:8, 9:12])
    robj   = visualize(points, :lines, indices=indices)
    #view(visualize((Circle(Point2f0(0), 5f0), points)), method=:orthographic_pixel)
    view(robj, method=:orthographic_pixel)
    robj, indices
end
function plot3(N)
    points = LineSegment{Point2f0}[LineSegment{Point2f0}((Point2f0(sin(i), cos(i))*50) + 200, (Point2f0(sin(i), cos(i))*200) + 200) for i=linspace(0,2*pi, N)]
    robj   = visualize(points)
    view(robj, method=:orthographic_pixel)
end
using GLVisualize, GeometryTypes, Colors, GLAbstraction, ModernGL, Reactive
w,r=glscreen(debugging=true)
@async r()
points = [Point2f0(offset, sin(offset/80)*100) for offset=linspace(0,1000, 4*3)]
last_length = 0
color = RGBA{U8}(1,0,0,1)
c = fill(color, length(points))
i = UnitRange{Int}[range(last_length+1, length(points))]
#push!(thicknesses, fill(thickness, length(points)))
positions = GLBuffer(fill(Point2f0(999999), 10_000))
colors    = GLBuffer(fill(RGBA{U8}(0,0,0,0), 10_000))
indices   = Signal(i)
positions[1:length(points)] = points
colors[1:length(points)] = c
robj = visualize(positions, :lines, color=colors, thickness=2f0, indices=indices)
view(robj, method=:orthographic_pixel)
function add_plot(points, x)
    global last_length, positions, colors, indices
    c = fill(RGBA{U8}(x), length(points))
    i = UnitRange{Int}[range(last_length+1, length(points))]
    positions[i[]] = points
    colors[i[]]    = c
    push!(indices, [value(indices); i])
    last_length += length(points)
end
