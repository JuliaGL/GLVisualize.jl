using GLVisualize, Colors, GeometryTypes, GLAbstraction, Reactive

if !isdefined(:runtests)
	window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end

description = """
Example that creates a 2D bar plot from a 1D array of floats.
"""

const N = 87
const range = linspace(-5f0, 5f0, N)

function contour_inner(i, x, y)
    Float32(sin(1.3*x*i)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x))
end
const data = zeros(Float32, N, N)

function contourdata(t)
    for i=1:size(data, 1)
        @simd for j=1:size(data, 2)
            @inbounds data[i,j] = contour_inner(t, range[i], range[j])
        end
    end
    data
end

heightfield = map(contourdata, timesignal)
mini = Vec3f0(first(range), first(range), minimum(value(heightfield)))
maxi = Vec3f0(last(range), last(range), maximum(value(heightfield)))
barsvis = visualize(
    heightfield,
    scale_x = 0.07,
    scale_y = 0.07,
    color_map=map(RGBA{N0f8}, colormap("Blues")),
    color_norm=Vec2f0(0,1),
    ranges=(range, range),
    boundingbox=Signal(AABB{Float32}(mini, maxi))
)
_view(barsvis, window)

if !isdefined(:runtests)
	renderloop(window)
end
