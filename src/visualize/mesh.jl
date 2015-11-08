_default(::AbstractMesh, ::Style, kw_args=Dict()) = Dict{Symbol, Any}()
_default(::GLNormalMesh, s::Style, kw_args=Dict()) = Dict{Symbol, Any}(
    :color => default(RGBA, s)
)

#visualize(mesh::Mesh, s::Style, customizations=visualize_default(mesh, s)) = visualize(convert(GLNormalMesh, mesh), s, customizations)


_visualize(mesh::NativeMesh{GLNormalMesh}, s::Style, data::Dict) = assemble_std(
    mesh.vertices, data,
    "util.vert", "standard.vert", "standard.frag"
)

_visualize(mesh::NativeMesh{GLNormalAttributeMesh}, s::Style, data::Dict) = assemble_std(
    mesh, data,
    "util.vert", "attribute_mesh.vert", "standard.frag",
)

_visualize(mesh::NativeMesh{GLNormalUVMesh}, s::Style, data::Dict) = assemble_std(
    mesh, data,
    "util.vert", "uv_normal.vert", "uv_normal.frag",
)
