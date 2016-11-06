using GLVisualize, GeometryTypes, GLAbstraction, ModernGL, FileIO, Reactive

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end

description = """
Showing bilboard particles, which always face the camera. Also showing how
to use Images as a particle primitive.
"""

rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

const b = Point3f0[(rand(Point3f0)*2)-1 for i=1:64]

sprites = visualize(
    (Circle(Point2f0(0), 0.25f0), b),
    billboard=true, image=loadasset("foxy.png"),
    model=rotation
)

_view(sprites, window, camera=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
