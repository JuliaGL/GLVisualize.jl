using GLVisualize, GLWindow, GLAbstraction, AxisArrays


if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end

description = """
Maximum intensity volume Plot.
"""

function volume_data(N)
    volume = Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
    max = maximum(volume)
    min = minimum(volume)
    volume = AxisArray((volume .- min) ./ (max .- min), (:y, :x, :z), (1, 1, 3))
end

volumedata = if isfile(joinpath(homedir(), "brain.nii"))
    using NIfTI # If we have, use some nice example data
    niread(joinpath(homedir(), "brain.nii")).raw  # TODO: make it an AxisArray
else
    volume_data(128)
end

volume = visualize(volumedata, :mip)

_view(volume, window)


if !isdefined(:runtests)
    renderloop(window)
end
