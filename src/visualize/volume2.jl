visualize_default(vol::Union{Array{Float32, 3}, Texture{Float32, 3}}, ::Style{:volume2}, kw_args=Dict()) = Dict(
    :hull                   => GLPlainMesh(Cube(Vec3(0), Vec3(1))),
    :u_shape                => Vec3(size(vol)...),
    :light_position         => Vec3(0.25, 1.0, 3.0),
    :color                  => RGBA{U8}[RGBA{U8}(1,0,0,1), RGBA{U8}(1,1,0,1), RGBA{U8}(0,1,0,1), RGBA{U8}(0,1,1,1), RGBA{U8}(0,0,1,1)],
    :light_intensity        => Vec3(15.0),
    :u_threshold            => 0.5f0,
    :u_relative_step_size   => 0.5f0
)

@visualize_gen Array{Float32, 3} Texture Style

function visualize(intensities::Texture{Float32, 3}, s::Style{:volume2}, customizations=visualize_default(intensities, s))
    @materialize! hull = customizations # pull out variables to avoid duplications
    customizations[:u_volumetex] = intensities
    data   = merge(customizations, collect_for_gl(hull))
    robj = assemble_std(
        hull.vertices, data,
        "volume2.vert", "volume2.frag",
    )
    robj[:prerender, glEnable]   = (GL_CULL_FACE,)
    robj[:prerender, glCullFace] = (GL_FRONT,)
    robj
end
