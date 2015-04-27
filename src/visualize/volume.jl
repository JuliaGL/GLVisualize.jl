visualize_default(::Union(Array{Float32, 3}, Texture{Float32, 3}), ::Style) = Dict(
    :hull                   => GLUVWMesh(Cube(Vec3(0), Vec3(1))),
    :light_position         => Input(Vec3(0.25, 1.0, 3.0)),
    :light_intensity        => Input(Vec3(15.0)),
    :absorption             => Input(1f0),
    :model                  => Input(eye(Matrix4x4{Float32})),
    :screen                 => ROOT_SCREEN
)

@visualize_gen Array{Float32, 3} Texture


function visualize(intensities::Texture{Float32, 3}, s::Style, customizations=visualize_default(intensities, s))
    @materialize! model, screen, absorption, hull = customizations # pull out variables to avoid duplications

    camera  = screen.perspectivecam
    data    = merge(@compat(Dict(
        :projection_view_model  => lift(*, camera.projectionview, model),
        :eye_position           => camera.eyeposition,

        :intensities            => intensities,
        :absorption             => absorption
    )), customizations, collect_for_gl(hull))

    shader = TemplateProgram(File(shaderdir, "volume.vert"), File(shaderdir, "volume.frag"))
    std_renderobject(data, shader)
end
