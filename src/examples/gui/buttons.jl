using GLVisualize, Colors, GeometryTypes, Reactive, GLAbstraction, GLWindow

if !isdefined(:runtests)
    window = glscreen()
end

const description = """
This example shows how easy it is to setup
a menu full of widgets which can be used
to configure a visualization interactively.
Click and slide around!
"""


const record_interactive = true

function lorenz(t0, a, b, c, h)
    Point3f0(
        t0[1] + h * a * (t0[2] - t0[1]),
        t0[2] + h * (t0[1] * (b - t0[3]) - t0[2]),
        t0[3] + h * (t0[1] * t0[2] - c * t0[3]),
    )
end
# step through the `time`
function lorenz(array::Vector, a=5.0,b=2.0,c=6.0,d=0.01)
    t0 = Point3f0(0.1, 0, 0)
    for i=eachindex(array)
        t0 = lorenz(t0, a,b,c,d)
        array[i] = t0
    end
    array
end

primitives = GLNormalMesh[
    loadasset("cat.obj"),
    Sphere(Point3f0(0), 1f0),
    Pyramid(Point3f0(0), 1f0, 1f0),
    HyperRectangle(Vec3f0(0), Vec3f0(1))
]

w = Dict(
    :colora => Signal(RGBA(0.7f0, 1f0, 0.5f0, 1f0)),
    :colorb => Signal(RGBA(1f0, 0f0, 0f0, 1f0)),
    :scale => Signal(0.4),
    :a => Signal(24f0),
    :b => Signal(10f0),
    :c => Signal(6.0f0),
    :d => Signal(0.01f0),
    :colornorm => Signal(Vec2f0(0, 1.2)),
    :primitive => primitives
)
editarea, viewarea = x_partition(window.area, 30f0)
editscreen = Screen(window, area=editarea, color=RGBA{Float32}(0.98, 0.98, 1, 1))
viewscreen = Screen(window, area=viewarea)
GLVisualize.extract_edit_menu(w, editscreen, true)

n1, n2 = 18, 30
N = n1*n2

args = map(value, (w[:a], w[:b], w[:c], w[:d]))
v0 = lorenz(zeros(Point3f0, N), args...)
positions = foldp(lorenz, v0, w[:a], w[:b], w[:c], w[:d])
scales = const_lift(Vec3f0, w[:scale])
rotations = map(diff, positions)
rotations = map(x-> push!(x, x[end]), rotations)
cmap = map((a,b)->[a,b], w[:colora], w[:colorb])

_view(visualize(
    (w[:primitive], positions),
    scale=scales, rotation=rotations,
    color_map=cmap, color_norm=w[:colornorm]
), viewscreen)

center!(viewscreen)

if !isdefined(:runtests)
    renderloop(window)
end
