visualize_default(::Mesh, ::Style, kw_args...) = Dict{Symbol, Any}()

#visualize(mesh::Mesh, s::Style, customizations=visualize_default(mesh, s)) = visualize(convert(GLNormalMesh, mesh), s, customizations)

function visualize(mesh::GLNormalMesh, s::Style, customizations=visualize_default(mesh, s))
    @materialize! screen, model = customizations
    camera = screen.perspectivecam
    data = merge(@compat(Dict(
        :viewmodel       => lift(*, model, camera.view),
        :projection      => camera.projection,
    )), collect_for_gl(mesh), customizations)

    shader  = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "standard.vert"), File(shaderdir, "standard.frag"))
    std_renderobject(data, shader)
end

function visualize(mesh::GLNormalAttributeMesh, s::Style, customizations=visualize_default(mesh, s))
    @materialize! screen, model = customizations
    camera = screen.perspectivecam
    data = merge(@compat(Dict(
        :viewmodel       => lift(*, model, camera.view),
        :projection      => camera.projection,
    )), collect_for_gl(mesh), customizations)
    shader  = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "attribute_mesh.vert"), File(shaderdir, "standard.frag"))
    std_renderobject(data, shader)
end
