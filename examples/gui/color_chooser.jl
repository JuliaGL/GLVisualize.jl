using GLVisualize, Colors, GeometryTypes, Reactive, GLAbstraction, GLWindow

if !isdefined(:runtests)
    window = glscreen()
end

description = """
Simple example showing how to create color choosers.
You can drag with right and left mouse click on the color to change it:
↔ right → red   | ↔ left → blue
↕ right → green | ↕ left → alpha
"""

color_a = Signal(RGBA{Float32}(1,0,0,0.7))
a_v, color_s = widget(color_a, window)

color_b = Signal(RGBA{Float32}(0,1,0,0.7))
b_v, color_s = widget(color_b, window)

color_c = Signal(RGBA{Float32}(0,0,1,0.7))
c_v, color_s = widget(color_c, window)
edit_screen = Screen(window, area=map(window.area) do a
    SimpleRectangle(0,0,60,a.h)
end)
_view(layout!(SimpleRectangle{Float32}(0,0,60,60), a_v), edit_screen, camera=:fixed_pixel)
_view(layout!(SimpleRectangle{Float32}(0,60,60,60), b_v), edit_screen, camera=:fixed_pixel)
_view(layout!(SimpleRectangle{Float32}(0,120,60,60), c_v), edit_screen, camera=:fixed_pixel)


function multirandomwalk(n1, n2)
    a = rand(Point3f0, n1)*2f0
    r = Array{Point3f0}(n1*n2)
    i = 1
    for j=1:n1
        pstart = a[j]
        for k=1:n2
            pstart += (rand(Point3f0)*2f0 - 1f0)*0.07f0
            r[i] = pstart
            i+=1
        end
    end
    r
end

a = multirandomwalk(15, 20)
b = multirandomwalk(15, 20)
c = multirandomwalk(15, 20)


_view(visualize(
    (Circle(Point2f0(0), 0.02f0), a),
    color=color_a, billboard=true
), window, camera=:perspective)

_view(visualize(
    (Circle(Point2f0(0), 0.02f0), b),
    color=color_b, billboard=true
), window, camera=:perspective)

_view(visualize(
    (Circle(Point2f0(0), 0.02f0), c),
    color=color_c, billboard=true
), window, camera=:perspective)


if !isdefined(:runtests)
    renderloop(window)
end
