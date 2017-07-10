using GLVisualize, GeometryTypes, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
end
description = """
Showing how one can color mesh vertices.
"""


# one could also create a GLNormalAttributeMesh manually:
sphere = Sphere{Float32}(Point3f0(0), 2f0)
# decompose decomposes a mesh or geometry into the primitive of the first argument
vertices = decompose(Point3f0, sphere, 50)
faces = decompose(GLTriangle, sphere, 50)
# create some colors for each vertex, must be Float32
colors = RGBA{Float32}[RGBA{Float32}(rand(), rand(), rand(), 1.) for i=1:length(vertices)]

sphere_mesh = GLNormalVertexcolorMesh(
    vertices = vertices, faces = faces,
    color = colors
)
_view(visualize(sphere_mesh), window)

if !isdefined(:runtests)
    renderloop(window)
end
