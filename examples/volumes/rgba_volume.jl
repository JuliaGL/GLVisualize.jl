using GLVisualize, GLWindow, Colors, FixedPointNumbers

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end

description = """
Direct RGBA rendering using an absorption model.
"""


function volume_data(N)
    vol     = Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
    max     = maximum(vol)
    min     = minimum(vol)
    vol     = (vol .- min) ./ (max .- min)
    vol     = map(x->RGBA{Float32}(x, 0, 1-x, 3.0), vol)
end

vol = visualize(volume_data(128), :absorption)
_view(vol, window)


if !isdefined(:runtests)
    renderloop(window)
end
