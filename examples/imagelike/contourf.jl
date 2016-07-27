using GLVisualize, GeometryTypes

if !isdefined(:runtests)
	window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end

# use the performance tips to speed this up
# (http://docs.julialang.org/en/release-0.4/manual/performance-tips/)
# the array is 512x512 after all
const N = 512
const range = linspace(-5f0, 5f0, N)

function contour_inner(i, x, y)
    Intensity{1,Float32}(sin(1.3*x*i)*cos(0.9*y)+cos(.8*x)*sin(1.9*y)+cos(y*.2*x))
end
const data = zeros(Intensity{1,Float32}, N, N)

function contourdata(t)
    for i=1:size(data, 1)
        @simd for j=1:size(data, 2)
            @inbounds data[i,j] = contour_inner(t, range[i], range[j])
        end
    end
    data
end

renderable = visualize(map(contourdata, timesignal))

_view(renderable, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
	renderloop(window)
end
