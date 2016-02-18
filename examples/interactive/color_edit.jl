using GLVisualize, Colors, ModernGL, GeometryTypes, GLAbstraction, GLWindow, FileIO
w = glscreen()
v, colortex = vizzedit(map(RGBA{U8}, colormap("blues", 7)), w)

robj = visualize(rand(Float32, 32,32), color_map=colortex, color_norn=Vec2f0(0,2))
view(robj, w)
view(v, w, camera=:fixed_pixel)

renderloop(w)
