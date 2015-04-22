

VolumeDefaults = Dict(
    :hull                   => GLUVWMesh(Cube(Vec3(0), Vec3(1))),
    :light_position         => Input(Vec3(0.25, 1.0, 3.0)),
    :light_intensity        => Input(Vec3(15.0)),
    :absorption             => Input(1f0),
    :model                  => Input(eye(Matrix4x4{Float32})),
    :screen                 => ROOT_SCREEN
)

visualize{T}(s::Style{:Default}, intensities::Signal{Array{T, 3}}, customizations=VolumeDefaults) = 
    visualize(s, Texture(intensities), customizations)

function visualize{T}(s::Style{:Default}, intensities::Signal{Array{T, 3}}, customizations=VolumeDefaults)
    tex = Texture(eltype(intensities.value), size(intensities.value))
    lift(update!, Input(tex), intensities)
    visualize(s, tex, customizations)
end


function visualize{T}(::Style{:Default}, intensities::Texture{T, 3}, customizations=VolumeDefaults)

    @materialize! model, screen, absorption = customizations # pull out variables to avoid duplications
    camera  = screen.perspectivecam

    data    = merge(@compat(Dict(
        #Vertex Shader Data
        :projection_view_model  => lift(*, camera.projectionview, model),
        :eye_position           => camera.eyeposition,

        #Frag Shader Data
        :intensities            => intensities,
        :absorption             => absorption
        
    )), customizations, collect_for_gl(customizations[:hull]))

    shader = TemplateProgram(File(shaderdir, "volume.vert"), File(shaderdir, "volume.frag"))
    robj   = RenderObject(data, shader)

    postrender!(robj, render, robj.vertexarray, GL_TRIANGLES)
    prerender!(robj,
        glEnable    , GL_DEPTH_TEST, 
        glEnable    , GL_BLEND, 
        glBlendFunc , GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,
        glEnable    , GL_CULL_FACE,
        glCullFace  , GL_FRONT
    )
    robj
end
