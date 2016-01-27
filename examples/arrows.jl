if !isdefined(:runtests)
    using GLVisualize, GeometryTypes, Reactive
    w= glscreen()
    N = 20
else
    N = 10
end
t = bounce(1.:0.1:2pi)
arrowfun(i) = Vec2f0[(sin(x/i), cos(y/(i/2f0))) for x=1:N, y=1:N]
flow = map(arrowfun, t)
vis = visualize(flow, xyrange=((50,800),(50,500)))
view(vis, method=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(w)
end
