using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive
w, r = glscreen(resolution=(256, 256))
empty!(w.cameras) #temporary fix for an ill designed default system

mesh 			= load("cat.obj")
rotation_angle  = Signal(0f0)
start_rotation  = Signal(rotationmatrix_x(deg2rad(90f0))) # the cat needs some rotation on the x axis to stand straight
rotation 		= map(rotationmatrix_y, map(deg2rad, rotation_angle))
final_rotation 	= map(*, start_rotation, rotation)
robj 			= visualize(mesh, model=final_rotation)

bb 				= boundingbox(robj).value
bb_width 		= width(bb)
lower_corner 	= minimum(bb)
middle 			= lower_corner + (bb_width/2f0)
lookatvec 		= minimum(bb)
eyeposition 	= middle + (bb_width.*Vec3f0(2,2,0))

view(robj, position = eyeposition, lookat=middle)

@async r()
num_img = 1
for i=1:4:360
	yield() # yield to render process
	sleep(0.01)
	push!(rotation_angle, i) # rotate around camera y axis.
	screenshot(w, channel=:depth, path=joinpath("images", "image$num_img.png"))
	num_img += 1
end
