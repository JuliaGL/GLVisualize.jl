using GLVisualize, GLWindow, GLAbstraction

function volume_data(N)
    volume = Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
    max = maximum(volume)
    min = minimum(volume)
    volume = (volume .- min) ./ (max .- min)
end

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end
const record_interactive = true

volumedata = if isfile(joinpath(homedir(), "brain.nii"))
    using NIfTI # If we have, use some nice example data
    niread(joinpath(homedir(), "brain.nii")).raw
else
    volume_data(128)
end

volume = visualize(volumedata, :mip)

_view(volume, window)


if !isdefined(:runtests)
    renderloop(window)
end
