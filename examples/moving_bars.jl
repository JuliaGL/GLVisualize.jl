using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO

w,r = glscreen()

const t    = Signal(0f0)
prima = SimpleRectangle(0f0,-0.5f0,1f0,1f0)

b = rand(10f0:0.01f0:200f0, 10)

interpolate(a,b,t) =
    [ae+((be-ae)*t) for (ae, be) in zip(a,b)]

interpolated = foldp((b,b,b), t) do v0_v1_ip, td
    v0,v1,ip = v0_v1_ip
    pol = td%1
    if isapprox(pol,0.0)
        v0 = v1
        v1 = map(x-> rand(linspace(-50f0, 60f0, 100)), v0)
    end
    v0,v1,interpolate(v0,v1,pol)
end
b_sig = map(last, interpolated)
a = visualize((RECTANGLE, b_sig), xyrange=((0,600),),intensity=b_sig, color_norm=Vec2f0(-40,200), color=Texture(GLVisualize.default(Vector{RGBA})))
view(a, method=:orthographic_pixel)
@async r()
for i=1:100
    sleep(0.1)
    yield()
end
N = 200
i = 1
for _t in 1f0:0.05f0:10f0
    yield()
    sleep(0.1)
    screenshot(w, path=joinpath(homedir(), "Videos","circles", @sprintf("frame%03d.png", i)))
    i+=1
    push!(t, _t)
end
