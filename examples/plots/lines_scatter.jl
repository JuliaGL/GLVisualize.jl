using Plots, GLVisualize, GeometryTypes, GLAbstraction
pl_size = if !isempty(GLVisualize.get_screens())
    widths(GLVisualize.current_screen())
else
    (800, 500)
end


description = """
Showing off different line types and marker types,
like 3D meshes, characters and images.
"""

glvisualize(size=pl_size)

ys = Vector[[sin(i*7)/x * cos(x^i) for x in linspace(0.6,5,10)] for i=1:5]
cat = loadasset("cat.obj")
cat = rotationmatrix_y(rad2deg(110)) * cat
marker = Any[:circle, :d, cat, loadasset("foxy.png"), '🐱']
marker = reshape(marker, (1, 5))
colors = reshape(colormap("Blues", 10)[4:8], (5, 1))

plot(
    ys,
    # color = colors,
    line = ([:dot :dash :dashdot :solid :dot], [1 2 3 4 5]),
    marker = marker,
    markersize = [5 10 20 10 15],
    # markercolor = reshape(colormap("RdBu", 5), (5, 1)),
    markerstrokewidth = [1 0.1 0 2 4],
    markerstrokecolor = [:blue :blue :black :blue :white],
)

gui()
