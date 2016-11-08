using GLVisualize, GLWindow

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end

description = """
Iso surface volume Plot.
"""


function volume_data(N)
    vol     = Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
    max     = maximum(vol)
    min     = minimum(vol)
    vol     = (vol .- min) ./ (max .- min)
end

vol = visualize(volume_data(128), :iso, isovalue=timesignal)
_view(vol, window)


if !isdefined(:runtests)
    renderloop(window)
end

