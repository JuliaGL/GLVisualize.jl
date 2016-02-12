using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive

w = glscreen()

robj         = visualize(rand(Float32, 32,32), :surface)
bb           = boundingbox(robj).value
bb_width     = widths(bb)
lower_corner = minimum(bb)
middle       = lower_corner + (bb_width/2f0)
lookatvec    = Signal(Vec3f0(0))
eyeposition  = Signal(Vec3f0(2))

ideal_eyepos = middle + (norm(bb_width)*Vec3f0(2,0,2))


theta, translation = GLAbstraction.default_camera_control(
    w.inputs, Signal(0.1f0), Signal(0.01f0)
)
upvector     = Signal(Vec3f0(0,0,1))

cam = PerspectiveCamera(
    theta,
    translation,
    lookatvec,
    eyeposition,
    upvector,
    w.inputs[:window_area],

    Signal(41f0), # Field of View
    Signal(1f0),  # Min distance (clip distance)
    Signal(100f0) # Max distance (clip distance)
)

w.cameras[:my_cam] = cam

view(robj, camera=:my_cam)

@async renderloop(w)
