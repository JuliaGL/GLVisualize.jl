using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive
w = glscreen()
empty!(w.cameras) #temporary fix for an ill designed default system

mesh 			= loadasset("cat.obj")
rotation_angle  = loop(1f0:4f0:360f0)
start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0))) # the cat needs some rotation on the x axis to stand straight
rotation 		= map(rotationmatrix_y, map(deg2rad, rotation_angle))
final_rotation 	= map(*, start_rotation, rotation)
robj 			= visualize(mesh, model=final_rotation)

bb 				= boundingbox(robj).value
bb_width 		= widths(bb)
lower_corner 	= minimum(bb)
middle 			= lower_corner + (bb_width/2f0)
lookatvec 		= minimum(bb)
eyeposition 	= middle + (bb_width.*Vec3f0(2,2,0))

view(robj, position = eyeposition, lookat=middle)

renderloop(w)
