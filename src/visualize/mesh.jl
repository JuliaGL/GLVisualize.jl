visualize_dafault(::Mesh, ::Style) = @compat(Dict(
    :screen     => ROOT_SCREEN, 
    :model      => Input(eye(Mat4)),
    :light      => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
))


visualize(mesh::Mesh, s::Style, customizations=visualize_dafault(mesh, s)) = visualize(convert(GLNormalMesh, mesh), customizations)

function visualize(mesh::GLNormalMesh, s::Style, customizations=visualize_dafault(mesh, s))
    @materialize! screen, model = customizations
    camera = screen.perspectivecam
    data = merge(@compat(Dict(
        :viewmodel       => lift(*, model, camera.view),
        :projection      => camera.projection,
    )), collect_for_gl(mesh), customizations)

    shader  = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "standard.vert"), File(shaderdir, "standard.frag"))
    std_renderobject(data, shader)
end
