# scalars can be uploaded directly to gpu, but not arrays
texture_or_scalar(x) = x
texture_or_scalar(x::Array) = Texture(x)
function texture_or_scalar{A <: Array}(x::Signal{A})
    tex = Texture(x.value)
    lift(update!, tex, x)
    tex
end


function visualize_default(particles::Union(Texture{Point3{Float32}, 2}, Array{Point3{Float32}, 2}), ::Style, kw_args...)
    color = get(kw_args[1], :color, RGBA(1f0, 0f0, 0f0, 1f0))
    delete!(kw_args[1], :color)
    color = texture_or_scalar(color)
    Dict(
        :primitive  => GLNormalMesh(Cube(Vec3(0), Vec3(1))),
        :color      => color,
        :scale      => Vec3(0.03)
    )
end
@visualize_gen Array{Point3{Float32}, 2} Texture
#=
function visualize(positions::Vector{Point3{Float32}}, s::Style, customizations=visualize_default(positions, s))
    len         = length(positions)
    estimate    = sqrt(len)
    pstride     = 2048
    if len % pstride != 0
        append!(positions, fill(Point3f(typemax(Float32)), pstride-(len%pstride))) # append if can't be reshaped with 1024
    end
    positions = reshape(positions, (pstride, div(length(positions), pstride)))
end
=#
function visualize(positions::Texture{Point3{Float32}, 2}, s::Style, customizations=visualize_default(positions, s))
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
        File(shaderdir, "standard.frag"), attributes=data)
    bb = lift(*,model, AABB(gpu_data(positions)))
    instanced_renderobject(data, length(positions), program, bb)
end


