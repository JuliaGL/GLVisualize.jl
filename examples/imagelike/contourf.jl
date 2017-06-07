using GLVisualize, GeometryTypes

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end
description = """
Simple animated contour plot. You need to press Ctrl to move the camera.
Most 2D camera's use the Ctrl modifier to make editing easier.
"""

# use the performance tips to speed this up
# (http://docs.julialang.org/en/release-0.4/manual/performance-tips/)
# the array is 512x512 after all
const N = 256
const range = linspace(-5f0, 5f0, N)
const data = zeros(Intensity{Float32}, N, N)

function contour_inner(i, x, y)
    Intensity{Float32}(sin(1.3*x*i)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x))
end

function contourdata(t)
    for i=1:size(data, 1)
        for j=1:size(data, 2)
            @inbounds data[i,j] = contour_inner(t, range[i], range[j])
        end
    end
    data
end

renderable = visualize(map(contourdata, timesignal), color_norm=Vec2f0(-3, 3))

_view(renderable, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
