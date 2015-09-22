GLVisualize.visualize_default{T <: Real}(::Union{Texture{Point{2, T}, 1}, Vector{Point{2, T}}}, ::Style, kw_args=Dict()) = Dict(
    :primitive          => GLUVMesh2D(Rectangle(-0.5f0, -0.5f0, 1f0, 1f0)),
    :scale              => Vec2f0(20),
    :shape              => RECTANGLE,
    :style              => Cint(OUTLINED) | Cint(FILLED),
    :stroke_width       => 4f0,
    :glow_width         => 4f0,
    :transparent_picking => false,
    :color              => RGBA{Float32}(0.3, 0.1, 0.9, 1.0),
    :stroke_color       => RGBA{Float32}(0.3, 0.1, 0.9, 1.0),
    :glow_color         => RGBA{Float32}(0.3, 0.1, 0.9, 1.0),
    :preferred_camera   => :orthographic_pixel
)

visualize(locations::Vector{Point{2, Float32}}, s::Style, customizations=visualize_default(locations, s)) =
    visualize(texture_buffer(locations), s, customizations)

function visualize(locations::Signal{Vector{Point{2, Float32}}}, s::Style, customizations=visualize_default(locations.value, s))
    start_val = texture_buffer(locations.value)
    lift(update!, start_val, locations)
    visualize(start_val, s, customizations)
end


function visualize{T <: Real}(
        positions::Texture{Point{2, T}, 1},
        s::Style, customizations=visualize_default(positions, s)
    )
    @materialize! primitive = customizations
    @materialize stroke_width, scale, glow_width = customizations
    data = merge(collect_for_gl(primitive), customizations)
    data[:positions] = positions
    data[:offset_scale] = lift(+, lift(/, stroke_width, Input(2)), glow_width, scale)
    
    robj = assemble_instanced(
        positions,
        data,
        "util.vert", "particles2D.vert", "distance_shape.frag",
    )
    empty!(robj.prerenderfunctions)
    prerender!(robj,
        glDisable, GL_DEPTH_TEST,
        glDepthMask, GL_FALSE,
        glDisable, GL_CULL_FACE,
        enabletransparency
    )
    robj
end


visualize_default{T <: Real}(::Rectangle{T}, ::Style, kw_args=Dict()) = Dict(
    :primitive          => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :shape              => Cint(RECTANGLE),
    :style              => Cint(OUTLINED) | Cint(FILLED),
    :stroke_width       => 2f0,
    :glow_width         => 2f0,
    :transparent_picking => false,
    :color              => RGBA{Float32}(0.3, 0.1, 0.9, 1.0),
    :stroke_color       => RGBA{Float32}(0.3, 0.1, 0.9, 1.0),
    :glow_color         => RGBA{Float32}(0.3, 0.1, 0.9, 1.0),
    :preferred_camera   => :orthographic_pixel
)

rectangle_position(r::Rectangle) = Point{2, Float32}(r.x, r.y)
rectangle_scale(r::Rectangle)    = Vec{2, Float32}(r.w, r.h)

visualize{T}(r::Rectangle{T}, s::Style, customizations=visualize_default(r.value, s)) = visualize(Input(r), s, customizations)
function visualize{T}(r::Signal{Rectangle{T}}, s::Style, customizations=visualize_default(r.value, s))
    @materialize! primitive = customizations
    @materialize stroke_width, glow_width = customizations
    scale = lift(rectangle_scale, r)
    data = merge(Dict(
        :position  => lift(rectangle_position, r),
        :scale     => scale,
        :offset_scale => lift(+, lift(/, stroke_width, Input(2)), glow_width, scale)
    ), collect_for_gl(primitive), customizations)

    robj = assemble_std(
        r, data,
        "particles2D_single.vert", "distance_shape.frag",
        boundingbox=lift(AABB{Float32}, r)
    )
    empty!(robj.prerenderfunctions)
    empty!(robj.postrenderfunctions)
    prerender!(robj,
        glDisable, GL_DEPTH_TEST,
        glDepthMask, GL_FALSE,
        glDisable, GL_CULL_FACE,
        enabletransparency
    )
    postrender!(robj,
        render, robj.vertexarray
    )
    robj
end
