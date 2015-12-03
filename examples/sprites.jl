using GLVisualize, GeometryTypes, GLAbstraction, ModernGL, FileIO, Reactive

w,r = glscreen()

cam = PerspectiveCamera(w.inputs, Vec3f0(1), Vec3f0(0))

const b = Point3f0[rand(Point3f0)*2 for i=1:64]


robj = visualize(b, scale=Vec3f0(0.03), image=loadasset("doge.png"))

view(robj, method=:perspective)
r()
