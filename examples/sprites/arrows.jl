using GLVisualize, GeometryTypes, Reactive

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0,1,360))
end
N = 20
# generate some rotations
function rotation_func(t)
    t = (t == 0f0 ? 0.01f0 : t)
    Vec2f0[(sin(x/t), cos(y/(t/2f0))) for x=1:N, y=1:N]
end

# us Reactive.map to transform the timesignal signal into the arrow flow
flow = map(rotation_func, timesignal)

# create a visualisation
vis = visualize(flow, ranges=(50:800,50:500))
view(vis, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
