# using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive

# w = glscreen()

# robj         = visualize(rand(Float32, 32,32), :surface)
# bb           = boundingbox(robj).value
# bb_width     = widths(bb)
# lower_corner = minimum(bb)
# middle       = lower_corner + (bb_width/2f0)
# lookatvec    = Signal(middle)
# eyeposition  = Signal(middle + (norm(bb_width)*Vec3f0(2,0,2)))

# theta 		 = Signal(Vec3f0(0))
# translation  = Signal(Vec3f0(0))

# w.cameras[:my_cam] = PerspectiveCamera(
#     w.inputs[:window_area],
#     eyeposition,
#     lookatvec,
#     theta,
#     translation,
#     Signal(41f0), # Field of View
#     Signal(1f0),  # Min distance (clip distance)
#     Signal(100f0) # Max distance (clip distance)
# )


# view(robj, camera=:my_cam)

# @async renderloop(w)
