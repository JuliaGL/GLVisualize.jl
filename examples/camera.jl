using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive
w = glscreen()

mesh         = loadasset("cat.obj")
robj         = visualize(mesh)
bb           = boundingbox(robj).value
bb_width     = widths(bb)
lower_corner = minimum(bb)
middle       = lower_corner + (bb_width/2f0)
lookatvec    = minimum(bb)
eyeposition  = middle + (bb_width.*Vec3f0(2,0,2))

theta = map(every(0.1)) do _
    Vec3f0(0,0.1,0) # add one degree on the camera y axis per 0.1 seconds
end

translation = Signal(Vec3f0(0))
zoom 		= Signal(0f0)

w.cameras[:my_cam] = PerspectiveCamera(
    w.inputs[:window_area],
    eyeposition,
    lookatvec,
    theta,
    translation,
    Signal(41f0), # Field of View
    Signal(1f0),  # Min distance (clip distance)
    Signal(100f0) # Max distance (clip distance)
)


view(robj, method=:my_cam)

renderloop(w)
