using GLVisualize, GeometryTypes, Reactive

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end
N = 7
# generate some rotations
function rotation_func(t)
    t = (t == 0f0 ? 0.01f0 : t)
    [Vec3f0(sin(x/t), cos(y/(t/2f0)), sqrt(t+z^2))*3f0 for x=1:N, y=1:N, z=1:N]
end

# us Reactive.map to transform the timesignal signal into the arrow flow
flow = map(rotation_func, timesignal)

# create a visualisation
s=step(linspace(0.,1.,N))
vis = visualize(flow, scale=Vec3f0(s,s,0.001))
_view(vis, window)

if !isdefined(:runtests)
    renderloop(window)
end
