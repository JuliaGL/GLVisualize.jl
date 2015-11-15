visualize_default(::Union{Array{Vec{3, Float32}, 3}, Texture{Vec{3, Float32}, 3}}, ::Style, kw_args) = @compat Dict(
    :primitive      => GLNormalMesh(Pyramid(Point{3, Float32}(0, 0,-0.5), 1f0, 0.2f0)),
    :boundingbox    => AABB{Float32}(Vec3f0(-1), Vec3f0(1)),
    :color_norm     => Vec2f0(-1,1),
    :color          => RGBA{UFixed8}[RGBA{U8}(1,0,0,1), RGBA{U8}(1,1,0,1), RGBA{U8}(0,1,0,1)]
)

function visualize(vectorfield::Texture{Vec{3, Float32}, 3}, s::Style, customizations=visualize_default(vectorfield, s))
    @materialize! color, primitive, boundingbox = customizations
    data = merge(Dict(
        :vectorfield    => vectorfield,
        :cube_min       => boundingbox.minimum,
        :cube_max       => boundingbox.maximum,
        :color          => Texture(color),
    ), customizations, collect_for_gl(primitive))
    # Depending on what the is, additional values have to be calculated
    program = assemble_instanced(
        vectorfield, data,
        "util.vert", "vectorfield.vert", "standard.frag",
        boundingbox=Signal(boundingbox)
    )
end

function visualize(vectorfield::Signal{Array{Vec{3, Float32}, 3}}, s::Style, customizations=visualize_default(vectorfield, s))
    tex = Texture(vectorfield.value, minfilter=:nearest, x_repeat=:clamp_to_edge)
    preserve(const_lift(update!, tex, vectorfield))
    visualize(tex, s, customizations)
end

function visualize(vectorfield::Array{Vec{3, Float32}, 3}, s::Style, customizations=visualize_default(vectorfield, s))
    _norm = map(norm, vectorfield)
    customizations[:color_norm] = Vec2f0(minimum(_norm), maximum(_norm))
    visualize(Texture(vectorfield, minfilter=:nearest, x_repeat=:clamp_to_edge), s, customizations)
end
