const VectorfieldDefaults = @compat Dict(
    :primitive      => GLNormalMesh(Cube(Vec3(-0.1,-0.1,-0.5), Vec3(0.1, 0.1, 0.5))),
    :boundingbox    => AABB(Vec3(-1), Vec3(1)),
    :norm           => Vec2(-1,1),
    :model          => Input(eye(Mat4)),
    :light          => Input(Vec3[Vec3(1.0,1.0,1.0), Vec3(0.1,0.1,0.1), Vec3(0.9,0.9,0.9), Vec4(20,20,20,1)]), 
    :screen         => ROOT_SCREEN, 
    :color_ramp     => RGBA{Ufixed8}[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1)]
)

visualize(positions::Array{Vector3{Float32}, 3}, s=Style{:Default}(); kw_args...) = 
    visualize(s, positions, merge(VectorfieldDefaults, Dict{Symbol, Any}(kw_args)))


function visualize(::Style{:Default}, vectorfield::Texture{Vector3{Float32}, 3}, customizations=VectorfieldDefaults)
    @materialize! screen, color_ramp, primitive, boundingbox = customizations
    camera       = screen.perspectivecam
    data = merge(@compat(Dict(
        :vectorfield    => vectorfield,
        :cube_min       => boundingbox.min,
        :cube_max       => boundingbox.max,
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :view           => camera.view,
    )), customizations, collect_for_gl(primitive))
    # Depending on what the is, additional values have to be calculated
    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "vectorfield.vert"), 
        File(shaderdir, "standard.frag"), 
    )

    robj = instancedobject(data, length(vectorfield), program, GL_TRIANGLES)
    prerender!(robj, 
        glEnable,       GL_DEPTH_TEST, 
        glDepthFunc,    GL_LEQUAL, 
        glDisable,      GL_CULL_FACE, 
        enabletransparency)
    robj
end

let texture_parameters = [
    (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
    (GL_TEXTURE_MAG_FILTER, GL_NEAREST),
    (GL_TEXTURE_WRAP_S,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_T,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_R,  GL_CLAMP_TO_EDGE),
  ]
function visualize(s::Style, vectorfield::Array{Vector3{Float32}, 3}, customizations=VectorfieldDefaults)
    _norm = map(norm, vectorfield)
    customizations[:norm] = Vec2(minimum(_norm), maximum(_norm))
    visualize(s, Texture(vectorfield, parameters=texture_parameters), customizations)
end
end
