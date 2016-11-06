using GLVisualize, GeometryTypes, Plots, GLWindow
using GLAbstraction
if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end
description = """
Combining GLVisualize with Plots.jl.
"""

plot_area, glv_area = y_partition(window.area, 50) # part parent area at 50%

# create one screen for Plots.jl
plot_screen = Screen(
    window, name=:plot, area=plot_area
)
# make it the current screen for plotting
GLVisualize.add_screen(plot_screen)
# tell Plots.jl the size of the window:
#
glvisualize(size=widths(plot_screen))

# one for GLVisualize
glv_screen = Screen(
    window, name=:glvisualize, area=glv_area
)

N = 10_000
_view(visualize(
    (Circle(Point3f0(0), 0.01f0), rand(Point3f0, N).*4f0),
    color = rand(RGBA{Float32}, N)
), glv_screen, camera=:perspective)

# plot one of the examples. This could be any Plots.plot command!
group = rand(map(i->"group $i",1:4),100)
plot(rand(100), layout=@layout([a b;c]), group=group, linetype=[:bar :scatter :steppre])
gui()

if !isdefined(:runtests)
    renderloop(window)
end
