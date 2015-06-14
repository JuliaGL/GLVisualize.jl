visualize_default(::Mesh, ::Style, kw_args=Dict()) = Dict{Symbol, Any}()
visualize_default(::GLNormalMesh, ::Style, kw_args=Dict()) = Dict{Symbol, Any}(
    :color      => RGBA(0.282f0,0.4627f0, 1.0f0, 1.0f0)
)

#visualize(mesh::Mesh, s::Style, customizations=visualize_default(mesh, s)) = visualize(convert(GLNormalMesh, mesh), s, customizations)

function visualize(mesh::GLNormalMesh, s::Style, customizations=visualize_default(mesh, s))
    data    = merge(collect_for_gl(mesh), customizations)
    shader  = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "standard.vert"), 
        File(shaderdir, "standard.frag"),
        fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")])
    std_renderobject(data, shader, Input(AABB(mesh.vertices)))
end

function visualize(mesh::GLNormalAttributeMesh, s::Style, customizations=visualize_default(mesh, s))
    data    = merge(collect_for_gl(mesh), customizations)
    shader  = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "attribute_mesh.vert"), 
        File(shaderdir, "standard.frag"),
        fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")])
    std_renderobject(data, shader, Input(AABB(mesh.vertices)))
end
