const MeshDefaults = @compat(Dict(
    :screen     => ROOT_SCREEN, 
    :model      => Input(eye(Mat4)),
    :light      => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]),
))

visualize(s::Style{:Default}, mesh::Mesh, customizations=MeshDefaults) = visualize(convert(GLNormalMesh, mesh), customizations)

function visualize(s::Style{:Default}, mesh::GLNormalMesh, customizations=MeshDefaults)
    @materialize! screen, model = customizations
    camera = screen.perspectivecam

    data = merge(@compat(Dict(
        :viewmodel       => lift(*, model, camera.view),
        :projection      => camera.projection,
    )), collect_for_gl(mesh), customizations)

    shader  = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "standard.vert"), File(shaderdir, "standard.frag"))
    robj    = RenderObject(data, shader)

    prerender!(robj, 
        glEnable, GL_DEPTH_TEST, 
        glDepthFunc, GL_LEQUAL, 
        glDisable, GL_CULL_FACE, 
        enabletransparency)
    postrender!(robj, render, robj.vertexarray)
    robj
end
