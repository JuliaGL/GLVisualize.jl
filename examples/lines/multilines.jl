using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive

if !isdefined(:runtests) # We use the examples to generate docs and tests
    window = glscreen()
end

description = """
This example draws multiple equally sized lines efficiently.
"""

vx = -10:0.1:10;
vy = -8:0.1:8;
x = [i for i in vx, j in vy];
y = [j for i in vx, j in vy];
xyz = map(x, y) do x, y
    z = (x * y * (x^2 - y^2) ./ (x^2 + y^2 + eps())) / 5.0
    Point3f0(x, y, z)
end

# ma
lines3d = visualize(
    xyz, :lines,
    thickness = 1f0
)
_view(lines3d, window, camera=:perspective)

if !isdefined(:runtests)
    renderloop(window)
end
