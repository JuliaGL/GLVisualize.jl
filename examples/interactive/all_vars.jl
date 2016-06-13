using GLVisualize, Reactive, GeometryTypes
using GLWindow, GLAbstraction, FixedSizeArrays, Colors


window = glscreen()
@async renderloop(window)

v, colortex = vizzedit(map(RGBA{U8}, colormap("RdBu", 7)), window)


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
view(v, edit_screen, camera=:fixed_pixel)

view(visualize(rand(Float32, 82,82), color_map=colortex, is_fully_opaque=false), viewing_screen)

#
# # create something to look at!
# bars = visualize(rand(Float32, 10,10), color=RGBA{Float32}(0,0,0,1),
# is_fully_opaque=false)
# robj = bars.children[]
# # view them in different screens
# view(bars, viewing_screen, camera=:perspective)
# x = filter(robj.uniforms) do k,v
#     !isa(v, Symbol) && !isa(v, Void)
# end
#
# function is_editable(k, v)
#     !(
#         k == :objectid ||
#         k == :is_fully_opaque ||
#         k == :instances ||
#         k == Symbol("position.multiplicator") ||
#         k == Symbol("position.dims") ||
#         k == Symbol("resolution") ||
#         k in fieldnames(PerspectiveCamera) ||
#         k == :instances ||
#         isa(v, Symbol) ||
#         isa(v, Void) ||
#         isa(v, NativeMesh) ||
#         isa(v, Bool) ||
#         isa(v, Integer)
#     )
# end
#
# pos = 0f0
# a_w = Float32(edit_screen.area.value.w)
# for (k,v) in x
#     is_editable(k, v) || continue
#     s = GLAbstraction.makesignal(v)
#     if applicable(vizzedit, s, window)
#         println(k)
#         sig, vis = vizzedit(s, window)
#         robj[k] = sig
#         GLAbstraction.transform!(vis, translationmatrix(Vec3f0(0,pos,0)))
#         view(vis, edit_screen, camera=:fixed_pixel)
#         pos += 50
#     end
# end
#
# # sig, viz = vizzedit(robj[:color_norm], window)
# # view(visualize(viz), edit_screen, camera=:orthographic_pixel)
