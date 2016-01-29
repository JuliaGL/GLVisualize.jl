using GLVisualize, GeometryTypes, GLAbstraction, ModernGL, FileIO, Reactive

w = glscreen()

const b = Point3f0[rand(Point3f0)*2 for i=1:64]

robj = visualize((SimpleRectangle(0f0,0f0,0.5f0, 0.5f0), b), billboard=true, image=loadasset("doge.png"))

view(robj, method=:perspective)
renderloop(w)
