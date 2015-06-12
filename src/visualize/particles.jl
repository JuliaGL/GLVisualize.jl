function Base.delete!(dict::Dict, key, default)
    haskey(dict, key) && return pop!(dict, key)
    return default
end
function visualize_default{T <: Point3}(
        particles::Union(Texture{T, 1}, Vector{T}), 
        s::Style, kw_args=Dict()
    )
    color = delete!(kw_args, :color, RGBA(1f0, 0f0, 0f0, 1f0))
    color = texture_or_scalar(color)
    Dict(
        :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(1))),
        :color      => color,
        :scale      => Vec3(0.03)
    )
end

@visualize_gen Vector{Point3{Float32}} texture_buffer Style

function visualize{T}(
        positions::Texture{Point3{T}, 1}, 
        s::Style, customizations=visualize_default(positions, s)
    )
    @materialize! screen, primitive, model = customizations
    camera = screen.perspectivecam
    data = merge(Dict(
        :positions       => positions,
        :projection      => camera.projection,
        :viewmodel       => lift(*, camera.view, model),
    ), collect_for_gl(primitive), customizations)

    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "particles.vert"), 
        File(shaderdir, "standard.frag"), 
        attributes=data
    )
    instanced_renderobject(data, length(positions), program, Input(AABB(gpu_data(positions))))
end


