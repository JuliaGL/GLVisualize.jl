visualize_default(::Union(Array{Vector3{Float32}, 3}, Texture{Vector3{Float32}, 3}), ::Style, kw_args) = @compat Dict(
    :primitive      => GLNormalMesh(Pyramid(Point3{Float32}(0,0,-0.5), 1f0, 0.2f0)),
    :boundingbox    => AABB(Vec3(-1), Vec3(1)),
    :norm           => Vec2(-1,1),
    :color          => RGBA{Ufixed8}[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1)]
)

function visualize(vectorfield::Texture{Vector3{Float32}, 3}, s::Style, customizations=visualize_default(vectorfield, s))
    @materialize! screen, color, primitive, boundingbox, model = customizations
    camera       = screen.perspectivecam
    data = merge(Dict(
        :vectorfield    => vectorfield,
        :cube_min       => boundingbox.min,
        :cube_max       => boundingbox.max,
        :color          => Texture(color),

        :projection     => camera.projection,
        :viewmodel      => lift(*, camera.view, model)
    ), customizations, collect_for_gl(primitive))
    # Depending on what the is, additional values have to be calculated
    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "vectorfield.vert"), 
        File(shaderdir, "standard.frag"), 
    )

    instanced_renderobject(data, length(vectorfield), program, Input(boundingbox))
end

let texture_parameters = [
    (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
    (GL_TEXTURE_MAG_FILTER, GL_NEAREST),
    (GL_TEXTURE_WRAP_S,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_T,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_R,  GL_CLAMP_TO_EDGE),
  ]

function visualize(vectorfield::Signal{Array{Vector3{Float32}, 3}}, s::Style, customizations=visualize_default(vectorfield, s))
    tex = Texture(vectorfield.value, parameters=texture_parameters)
    lift(update!, tex, vectorfield)
    visualize(tex, s, customizations)
end
function visualize(vectorfield::Array{Vector3{Float32}, 3}, s::Style, customizations=visualize_default(vectorfield, s))
    _norm = map(norm, vectorfield)
    customizations[:norm] = Vec2(minimum(_norm), maximum(_norm))
    visualize(Texture(vectorfield, parameters=texture_parameters), s, customizations)
end
end
