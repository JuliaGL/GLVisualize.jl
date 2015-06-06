visualize_default(::Union(Array{Float32, 3}, Texture{Float32, 3}), ::Style, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube(Vec3(0), Vec3(1))),
    :light_position         => Vec3(0.25, 1.0, 3.0),
    :light_intensity        => Vec3(15.0),
    :algorithm              => 3f0,
)

visualize_default(::Union(Array{Float32, 3}, Texture{Float32, 3}), ::Style{:mip}, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube(Vec3(0), Vec3(1))),
    :light_position         => Vec3(0.25, 1.0, 3.0),
    :light_intensity        => Vec3(15.0),
    :algorithm              => 3f0,
)
visualize_default(::Union(Array{Float32, 3}, Texture{Float32, 3}), ::Style{:iso}, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube(Vec3(0), Vec3(1))),
    :light_position         => Vec3(0.25, 1.0, 3.0),
    :light_intensity        => Vec3(15.0),
    :isovalue               => 0.5f0,
    :algorithm              => 2f0,
)
visualize_default(::Union(Array{Float32, 3}, Texture{Float32, 3}), ::Style{:absorption}, kw_args...) = Dict(
    :hull                   => GLUVWMesh(Cube(Vec3(0), Vec3(1))),
    :light_position         => Vec3(0.25, 1.0, 3.0),
    :light_intensity        => Vec3(15.0),
    :absorption             => 1f0,
    :algorithm              => 1f0,
)

@visualize_gen Array{Float32, 3} Texture Style

to_modelspace(x, model) = Vec3(inv(model)*Vec4(x...,1))
    
function visualize(intensities::Texture{Float32, 3}, s::Style, customizations=visualize_default(intensities, s))
    @materialize! model, screen, hull = customizations # pull out variables to avoid duplications

    camera  = screen.perspectivecam
    data    = merge(@compat(Dict(
        :projection_view_model  => lift(*, camera.projectionview, model),
        :eye_position           => lift(to_modelspace, camera.eyeposition, model),
        :intensities            => intensities,
    )), customizations, collect_for_gl(hull))

    shader = TemplateProgram(File(shaderdir, "volume.vert"), File(shaderdir, "volume.frag"))
    std_renderobject(data, shader, Input(AABB(hull.vertices)))
end
