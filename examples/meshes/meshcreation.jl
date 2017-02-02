using GLVisualize, GeometryTypes, GLAbstraction, Colors

if !isdefined(:runtests)
	window = glscreen()
end

description = """
Example that will walk through the basic steps to create a mesh with colors from
Geometry primitives.
"""

baselen = 0.4f0
dirlen = 2f0
# create an array of differently colored boxes in the direction of the 3 axes
rectangles = [
    (HyperRectangle{3,Float32}(Vec3f0(baselen), Vec3f0(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)),
    (HyperRectangle{3,Float32}(Vec3f0(baselen), Vec3f0(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)),
    (HyperRectangle{3,Float32}(Vec3f0(baselen), Vec3f0(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
]
# convert to an array of normal meshes
# note, that the constructor is a bit weird. GLNormalMesh takes a tuple of
# a geometry and a color. This means, the geometry will be converted to a GLNormalMesh
# and the color will be added afterwards, so the resulting type is a GLNormalColorMesh
meshes = map(GLNormalMesh, rectangles)
# merge them into one big mesh
# the resulting type is a GLNormalAttributeMesh, since we merged meshes with different
# attributes (colors). An array of the colors will be created and each vertex in the
# mesh will be asigned to one of the colors found there.
colored_mesh = merge(meshes)
_view(visualize(colored_mesh), window)

# one could also create a GLNormalAttributeMesh manually:
sphere = Sphere{Float32}(Point3f0(0), 2f0)
# decompose decomposes a mesh or geometry into the primitive of the first argument
vertices = decompose(Point3f0, sphere, 50)
faces = decompose(GLTriangle, sphere, 50)

# create a few colors, can be N0f8 or Float32
colors = RGBA{N0f8}[RGBA{N0f8}(rand(), rand(), rand(), 1.) for i=1:5]
# assign every vertice a random index into the color array (0-based indexes)
attribute_id = rand(0f0:4f0, length(vertices))

sphere_mesh = GLNormalAttributeMesh(
    vertices=vertices, faces=faces,
    attributes=colors, attribute_id=attribute_id
)

# move the model a bit to the right
moveright = translationmatrix(Vec3f0(5,0,0))

_view(visualize(sphere_mesh, model=moveright), window)

if !isdefined(:runtests)
	renderloop(window)
end
