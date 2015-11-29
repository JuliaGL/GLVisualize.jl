GLVisualize.visualize_default{T <: Point{2}}(::Union{Texture{T, 1}, Vector{T}}, s::Style{:default}, kw_args=Dict()) = Dict(
    :primitive          => GLUVMesh2D(SimpleRectangle(-0.5f0, -0.5f0, 1f0, 1f0)),
    :scale              => Vec2f0(20),
    :shape              => RECTANGLE,
    :style              => OUTLINED|FILLED,
    :stroke_width       => 4f0,
    :glow_width         => 4f0,
    :transparent_picking => false,
    :color              => default(RGBA, s),
    :stroke_color       => RGBA{Float32}(0.9, 0.9, 1.0, 1.0),
    :glow_color         => RGBA{Float32}(0.,0.,0., 0.7),
    :preferred_camera   => :orthographic_pixel
)

visualize{T<:Point{2}}(locations::Vector{T}, s::Style, customizations=visualize_default(locations, s)) =
    visualize(texture_buffer(locations), s, customizations)

function visualize{T<:Point{2}}(locations::Signal{Vector{T}}, s::Style{:default}, customizations=visualize_default(locations.value, s))
    start_val = texture_buffer(locations.value)
    preserve(const_lift(update!, start_val, locations))
    visualize(start_val, s, customizations)
end



function visualize{T <: Point{2}}(
        positions::Texture{T, 1},
        s::Style, customizations=visualize_default(positions, s)
    )
    @materialize! primitive = customizations
    @materialize stroke_width, scale, glow_width = customizations
    data = merge(collect_for_gl(primitive), customizations)
    data[:positions] = positions
    data[:offset_scale] = const_lift(+, const_lift(/, stroke_width, Signal(2)), glow_width, scale)
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


visualize_default{T <: Real}(::SimpleRectangle{T}, ::Style, kw_args=Dict()) = Dict(
    :primitive          => GLUVMesh2D(SimpleRectangle(0f0, 0f0, 1f0, 1f0)),
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

rectangle_position(r::SimpleRectangle) = Point{2, Float32}(r.x, r.y)
rectangle_scale(r::SimpleRectangle)    = Vec{2, Float32}(r.w, r.h)

visualize{T}(r::SimpleRectangle{T}, s::Style, customizations=visualize_default(r.value, s)) = visualize(Signal(r), s, customizations)
function visualize{T}(r::Signal{SimpleRectangle{T}}, s::Style, data=visualize_default(r.value, s))
    xy = Point2f0(r.value.x, r.value.y)
    wh = Vec2f0(r.value.w, r.value.h)
    data[:scale] = wh
    visualize([xy], s, data)
end
