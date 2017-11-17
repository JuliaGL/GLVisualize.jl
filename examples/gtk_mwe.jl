using GLWindow, ModernGL, GLAbstraction, Reactive, GeometryTypes, Colors, GLVisualize
using Gtk, ModernGL

resolution = (600, 500)
name = "GTK + GLVisualize"
parent = Gtk.Window(name, resolution..., true, true)
Gtk.visible(parent, true)
Gtk.setproperty!(parent, Symbol("is-focus"), false)
box = Gtk.Box(:v)
push!(parent, box)

sl = Gtk.Scale(false, linspace(0, 1, 100))
push!(box, sl)
gl_area = Gtk.GLArea()
Gtk.gl_area_set_required_version(gl_area, 3, 3)
push!(box, gl_area)
Gtk.setproperty!(box, :expand, gl_area, true)
adj = Gtk.Adjustment(sl)

Gtk.signal_connect(gl_area, "render") do gl_area, gdk_context
    val = getproperty(adj, :value, Float64)
    glClearColor(val, 0,0,1)
    glClear(GL_COLOR_BUFFER_BIT)
    glFlush()
    return false
end

Gtk.showall(parent)
# Gtk.gtk_main()


prerender=()->glDisable(GL_DEPTH_TEST), # draw over other items
postrender=()->glEnable(GL_DEPTH_TEST)


_view(visualize(
    points, :lines, indices = indices,
    prerender=()->glDisable(GL_DEPTH_TEST), # draw over other items
    postrender=()->glEnable(GL_DEPTH_TEST)
), w, camera = :fixed_pixel)
