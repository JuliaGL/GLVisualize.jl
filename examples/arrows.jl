using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO
w,r = glscreen()
const t = Signal(1f0)
flow = map(i->Vec2f0[(sin(x/i), cos(y/(i/2f0))) for x=1:20, y=1:20], t)
vis = visualize(flow, xyrange=((50,800),(50,500)))
view(vis, method=:orthographic_pixel)
@async r()
sleep(2)
i = 1
for _t in 1f0:0.05f0:(Float32(2pi)+1)
    yield()
    sleep(0.1)
    screenshot(w, path=joinpath(homedir(), "Videos","circles", @sprintf("frame%03d.png", i)))
    i+=1
    push!(t, _t)
end
