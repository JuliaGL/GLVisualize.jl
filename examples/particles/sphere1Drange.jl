using GLVisualize, GeometryTypes, Reactive, GLAbstraction

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0, 1f0,360))
end
description = """
You can simply visualize a range with the particle system. The positions
will be placed on a 1D grid.
"""

# last argument can be used to control the granularity of the resulting mesh
sphere = GLNormalMesh(Sphere(Point3f0(0.5), 0.5f0), 24)
c = collect(linspace(0.1f0,1.0f0,10f0))
rotation = map(rotationmatrix_z, const_lift(*, timesignal, 2f0*pi))
# create a visualisation
vis = visualize((sphere, c))
_view(vis, window)

if !isdefined(:runtests)
    renderloop(window)
end
