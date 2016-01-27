using GLVisualize, GeometryTypes, Colors, ModernGL, Reactive, GLAbstraction
w = glscreen()
x = HyperSphere(Point3f0(0), 1f0)

rotation_angle  = Signal(0f0)
rotation 		= map(rotationmatrix_z, map(deg2rad, rotation_angle))

positions = decompose(Point3f0, x)
indices = rand(range(Cuint(0), Cuint(length(positions))), 1000)
color = map(x->RGBA{Float32}(x, 0.9f0), colormap("Blues", length(positions)))
color2 = map(x->RGBA{Float32}(x, 1f0), colormap("Blues", length(positions)))
view(visualize(positions, :linesegment, thickness=0.5f0, color=color, indices=indices, model=rotation), method=:perspective)
view(visualize((Sphere{Float32}(Point3f0(0.0), 1f0), positions), color=color2, scale=Vec3f0(0.05), model=rotation))
GLWindow.renderloop(w)
