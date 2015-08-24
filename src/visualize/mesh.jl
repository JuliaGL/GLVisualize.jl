visualize_default(::Mesh, ::Style, kw_args=Dict()) = Dict{Symbol, Any}()
visualize_default(::GLNormalMesh, ::Style, kw_args=Dict()) = Dict{Symbol, Any}(
    :color      => RGBA(0.282f0,0.4627f0, 1.0f0, 1.0f0)
)

#visualize(mesh::Mesh, s::Style, customizations=visualize_default(mesh, s)) = visualize(convert(GLNormalMesh, mesh), s, customizations)

function visualize(mesh::GLNormalMesh, s::Style, customizations=visualize_default(mesh, s))
    data    = merge(collect_for_gl(mesh), customizations)
    shader  = assemble_std(
        mesh.vertices, data,
        "util.vert", "standard.vert", "standard.frag"
    )
end

function visualize(mesh::GLNormalAttributeMesh, s::Style, customizations=visualize_default(mesh, s))
    data = merge(collect_for_gl(mesh), customizations)
    assemble_std(
        mesh.vertices, data,
        "util.vert", "attribute_mesh.vert", "standard.frag",
    )
end



function visualize(mesh::GLNormalUVMesh, s::Style, customizations=visualize_default(mesh, s))
    data = merge(collect_for_gl(mesh), customizations)
    assemble_std(
        mesh.vertices, data,
        "util.vert", "uv_normal.vert", "uv_normal.frag",
    )
end
