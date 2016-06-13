using GLVisualize, Reactive, GeometryTypes
using GLWindow, GLAbstraction, FixedSizeArrays, Colors


window = glscreen()
@async renderloop(window)

# const static_example = true
# """
# functions to halve some rectangle
# """
xhalf(r)  = SimpleRectangle(r.x, r.y, r.w÷2, r.h)
xhalf2(r) = SimpleRectangle(r.w÷2, r.y, r.w÷2, r.h)

# create first screen with window as the parent screen
# and a different area.
edit_screen = Screen(
    window, name=:edit_screen,
    area=const_lift(xhalf2, window.area)
)
# create second screen with window as the parent screen
# and a different area.
viewing_screen = Screen(
    window, name=:viewing_screen,
    area=const_lift(xhalf, window.area)
)
# v1 = visualize(colortex, is_fully_opaque=false)
# rect1 = map(edit_screen.area) do a
#     h = 50
#     SimpleRectangle(0,a.h-h, a.w, h)
# end
# rect2 = map(rect1) do a
#     h = 300
#     SimpleRectangle(0,a.y-h, a.w, h)
# end
# view(layout!(rect1, v1), edit_screen, camera=:fixed_pixel)

view(visualize(rand(Float32, 82,82), is_fully_opaque=false), viewing_screen)

#
# # create something to look at!
# bars = visualize(rand(Float32, 10,10), color=RGBA{Float32}(0,0,0,1),
# is_fully_opaque=false)
# robj = bars.children[]
# # view them in different screens
# view(bars, viewing_screen, camera=:perspective)

function is_editable(k, v)
    !(
        k == :objectid ||
        k == :is_fully_opaque ||
        k == :instances ||
        k == Symbol("position.multiplicator") ||
        k == Symbol("position.dims") ||
        k == Symbol("resolution") ||
        k in fieldnames(PerspectiveCamera) ||
        k == :instances ||
        isa(v, Symbol) ||
        isa(v, Void) ||
        isa(v, NativeMesh) ||
        isa(v, Bool) ||
        isa(v, Integer)
    )
end
makesignal2(s::Signal)   = s
makesignal2(v)           = Signal(v)
makesignal2(v::GPUArray) = v

pos = Float32(edit_screen.area.value.h) - 5
a_w = Float32(edit_screen.area.value.w)
robj = viewing_screen.renderlist[]
for (k,v) in robj.uniforms
    is_editable(k, v) || continue
    s = makesignal2(v)
    if applicable(vizzedit, s, edit_screen)
        println(k)
        sig, vis = vizzedit(s, edit_screen)
        robj[k] = sig
        bb = value(boundingbox(vis))
        height = widths(bb)[2]
        min = minimum(bb)
        max = maximum(bb)
        to_origin = Vec3f0(min[1], max[2], min[3])
        GLAbstraction.transform!(vis, translationmatrix(Vec3f0(20,pos,0)-to_origin))
        view(vis, edit_screen, camera=:fixed_pixel)
        pos -= height + 20
    end
end

# sig, viz = vizzedit(robj[:color_norm], window)
# view(visualize(viz), edit_screen, camera=:orthographic_pixel)
