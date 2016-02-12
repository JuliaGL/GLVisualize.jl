# using GLVisualize, Colors, ModernGL, GeometryTypes, GLAbstraction, GLWindow, FileIO
# w = glscreen()
# v, colortex = vizzedit(map(RGBA{U8}, colormap("blues", 7)), w)

# function screen(robj, w)
# 	bb = boundingbox(robj)
# 	area = const_lift(bb) do b
# 		m = Vec{2,Int}(b.minimum)
# 		SimpleRectangle{Int}(m..., (Vec{2,Int}(b.maximum+30)-m)...)
# 	end
# 	s = Screen(w, area=area)
# 	transformation(robj, translationmatrix(Vec3f0(15,15,0)))
# 	view(robj, s, camera=:fixed_pixel)
# 	s
# end

# screen(v, w)
# view(visualize(rand(Float32, 28,92), color=colortex, color_norm=Vec2f0(0,1)))
# renderloop()
