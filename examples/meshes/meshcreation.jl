using GLVisualize, GeometryTypes, GLAbstraction, Colors

if !isdefined(:runtests)
	window = glscreen()
end
const static_example = true

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
view(visualize(colored_mesh), window)

# one could also create a GLNormalAttributeMesh manually:
colors = RGBA{U8}[RGBA{U8}(rand(), rand(), rand(), 1.0) for i=1:50]
sphere = Sphere{Float32}(Point3f0(0), 2f0)
# decompose decomposes a mesh or geometry into the primitive of the first argument
vertices = decompose(Point3f0, sphere)
faces = decompose(GLTriangle, sphere)
# assign every vertice a random index into the color array (0-based indexes)
attribute_ids = Float32[rand(0:49) for i=1:length(vertices)]

sphere_mesh = GLNormalAttributeMesh(
    vertices=vertices, faces=faces,
    attributes=colors, attribute_id=attribute_ids
)

# move the model a bit to the right
moveright = translationmatrix(Vec3f0(5,0,0))

view(visualize(sphere_mesh, model=moveright), window)

if !isdefined(:runtests)
	renderloop(window)
end
