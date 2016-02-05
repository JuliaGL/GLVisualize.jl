if !isdefined(:runtests)
    using GLVisualize, GeometryTypes, Reactive
    window = glscreen()
    time = bounce(1.:0.1:2pi)
end
N = 20
# generate some rotations
rotation_func(i) = Vec2f0[(sin(x/i), cos(y/(i/2f0))) for x=1:N, y=1:N]

# us Reactive.map to transform the time signal into the arrow flow
flow = map(rotation_func, time)

# create a visualisation
vis = visualize(flow, xyrange=((50,800),(50,500)))
view(vis, window, method=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
