#=
const MeshDefaults = Dict(
    :light           => Vec3[Vec3(1.0,0.9,0.8), Vec3(0.01,0.01,0.1), Vec3(1.0,0.9,0.9), Vec3(-5.0, -7.0,10.0)],
    :model           => eye(Mat4),
    :screen          => ROOT_SCREEN,
)

visualize(s::Style{:Default}, mesh::Mesh, customizations=MeshDefaults) = visualize(convert(GLNormalMesh, mesh), customizations)

function visualize(s::Style{:Default}, mesh::GLNormalMesh, customizations=MeshDefaults)
    @materialize! screen = customizations
    camera = screen.perspectivecam

    data = merge(@compat(Dict(
        :view            => camera.view,
        :projection      => camera.projection,
    )), collect_for_gl(mesh), customizations)

    shader  = TemplateProgram(File(shaderdir, "standard.vert"), File(shaderdir, "phongblinn.frag"))
    robj    = RenderObject(data, shader)

    prerender!(robj, 
        glEnable, GL_DEPTH_TEST, 
        glDepthFunc, GL_LEQUAL, 
        glDisable, GL_CULL_FACE, 
        enabletransparency)
    postrender!(robj, render, robj.vertexarray)
    robj
end
=#