using GLVisualize, GeometryTypes, FileIO
using GLAbstraction, Colors, Reactive

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end

description = """
Example that shows how to set up a camera to watch your particles better.
"""

cube = HyperRectangle(Vec3f0(0), Vec3f0(0.05))
n = 20
const wx,wy,wz = widths(cube)

mesh = GLNormalMesh(cube)

timepi = const_lift(*, timesignal, 2f0*pi)
function position(t, x, y)
    pos = Point3f0(x*(sqrt(wx^2+wy^2)), -y*wy, y*wz)
    dir = Point3f0(0, wy, wz)
    pos = pos + sin(t)*dir
end
position_signal = map(timepi) do t
    vec(Point3f0[position(t,x,y) for x=1:n, y=1:n])
end

rotation = map(timepi) do t
    vec(Vec3f0[Vec3f0(cos(t+(x/7)),sin(t+(y/7)), 1) for x=1:20, y=1:20])
end

cubes = visualize(
    (mesh, position_signal),
    rotation=rotation,
    color_map=GLVisualize.default(Vector{RGBA}),
    color_norm=Vec2f0(1,1.8)
    # intensity that will define the color sampled from color_map will fallback
    # to the length of the rotation vector.
    # you could also supply it via intensity = Vector{Float32}
)

# we create our own camera to better adjust to what we want to see.
camera = PerspectiveCamera(
    Signal(Vec3f0(0)), # theta (rotate by x around cam xyz axis)
    Signal(Vec3f0(0)), # translation (translate by translation in the direction of the cam xyz axis)
    Signal(Vec3f0(wx*n+4wx,wy*n,wz*n)/2), # lookat. We want to look at the middle of the cubes
    Signal(Vec3f0(((wx*n+4wx)/2),1.2*wy*n,(wz*n)/2)), # camera position. We want to be on the same height, but further away in y
    Signal(Vec3f0(0,0,1)), #upvector
    window.area, # window area

    Signal(41f0), # Field of View
    Signal(1f0),  # Min distance (clip distance)
    Signal(100f0), # Max distance (clip distance)
    Signal(GLAbstraction.ORTHOGRAPHIC)
)
_view(cubes, window, camera=camera)


if !isdefined(:runtests)
    renderloop(window)
end
