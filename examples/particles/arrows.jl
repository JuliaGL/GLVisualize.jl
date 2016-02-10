if !isdefined(:runtests)
    using GLVisualize, GeometryTypes, Reactive
    window = glscreen()
    timesignal = bounce(linspace(0,1,360))
end
N = 20
# generate some rotations
rotation_func(i) = Vec2f0[(sin(x/i), cos(y/(i/2f0))) for x=1:N, y=1:N]

i_signal = map(x-> x*2pi + 0.1, timesignal)
# us Reactive.map to transform the timesignal signal into the arrow flow
flow = map(rotation_func, i_signal)

# create a visualisation
vis = visualize(flow, xyrange=((50,800),(50,500)))
view(vis, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end