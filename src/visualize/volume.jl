abstract Mesh{Triangle}

typealias UVWMesh Mesh{Triangle}

Defaults = Dict(
    :hull                   => GLUVMesh(Cube(Vec3(-1), Vec3(1))),
    :light_position         => Input(Vec3(0.25, 1.0, 3.0)),
    :light_intensity        => Input(Vec3(15.0)),
    :absorption             => Input(1f0),
    :model                  => Input(eye(Matrix4x4{Float32})),
    :screen                 => ROOT_SCREEN
)
function visualize{T}(::Style{:Default}, intensities::Texture{T, 1}, customizations)

    @materialize! model, screen = customizations # pull out variables to avoid duplications
    camera  = screen.perspectivecam

    data    = merge(Dict(
        #Vertex Shader Data
        :projection_view_model  => lift(*, camera.projectionview, model)
        :eye_position           => camera.eyeposition,

        #Frag Shader Data
        :intensities            => intensities,
        :absorption             => absorption
        
    ), customizations, collect_for_gl(customizations[:hull]))

    shader = TemplateProgram(File("volume.vert"), File("volume.frag"))
    robj   = RenderObject(data, shader)

    postrender(robj, render, obj.vertexarray, GL_TRIANGLES)
    prerender!(robj,
        glEnable    , GL_DEPTH_TEST, 
        glEnable    , GL_BLEND, 
        glBlendFunc , GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,
        glEnable    , GL_CULL_FACE,
        glCullFace  , GL_FRONT
    )
    robj
end
