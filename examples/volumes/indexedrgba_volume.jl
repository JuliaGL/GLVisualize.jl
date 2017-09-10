using GLVisualize, GLWindow, Colors, IndirectArrays

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end

description = """
Iso surface volume Plot.
"""


function volume_data(N)
    id = zeros(UInt32, N, N, N)
    id[:, :, 1:N÷2] = 1
    id[:, :, N÷2+1:N] = 2
    vol = IndirectArray(id, [RGBA{N0f8}(1,0,0,1), RGBA{N0f8}(0,0,1,1)])
end

vol = visualize(volume_data(128), :absorption)
_view(vol, window)


if !isdefined(:runtests)
    renderloop(window)
end
