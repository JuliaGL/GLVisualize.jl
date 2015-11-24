using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive
w, r = glscreen()

mesh 			= load("cat.obj")
robj 			= visualize(mesh)
bb 				= boundingbox(robj).value
bb_width 		= width(bb)
lower_corner 	= minimum(bb)
middle 			= lower_corner + (bb_width/2f0)
lookatvec 		= minimum(bb) 
eyeposition 	= middle + (bb_width.*Vec3f0(2,0,2))

const option = 2
if option == 1
	theta = map(every(0.1)) do _
		Vec3f0(0,0.1,0) # add one degree on the camera y axis per 0.1 seconds
		#screenshot(w)
	end
else
	theta = Signal(Vec3f0(0))
end

translation = Signal(Vec3f0(0))
zoom 		= Signal(0f0)

w.cameras[:my_cam] = PerspectiveCamera(
    w.inputs[:window_size],
    eyeposition,
    lookatvec,
    theta,
    translation,
    zoom,
    Signal(41f0), # Field of View
    Signal(1f0),  # Min distance (clip distance)
    Signal(100f0) # Max distance (clip distance)
)


view(robj, method=:my_cam)

if option == 1
	r()
else
	@async r()
	for i=1:180
		yield() # yield to render process
		sleep(0.01) # let render
		push!(theta, Vec3f0(0,deg2rad(1),0)) # rotate around camera y axis. 
		screenshot(w, channel=:depth, path=joinpath("images", "image$i.png"))
	end
end

#Option 2
