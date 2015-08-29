visualize_default{T <: Real}(::Union(Texture{Point{2, T}, 1}, Vector{Point{2, T}}), ::Style, kw_args=Dict()) = Dict(
    :primitive          => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :color              => RGBA(1f0, 0f0, 0f0, 1f0),
    :scale              => Vec2f0(50),
    :technique          => :circle,
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
    @materialize! primitive, technique = customizations
    data = merge(Dict(
        :positions           => positions,
        :technique           => lift(to_gl_technique, technique)
    ), collect_for_gl(primitive), customizations)

    assemble_instanced(
        positions,
        data,
        "util.vert", "particles2D.vert", "distance_shape.frag",
    )
end

#=
begin
local const POSITIONS = GPUVector{Point{2, Float32}}[]
local const SCALE     = GPUVector{Vec{2, Float32}}[]
getposition()   = isempty(POSITIONS) ? push!(POSITIONS, GPUVector(texture_buffer(Point{2, Float32}[])))[] : POSITIONS[]
getscale()      = isempty(SCALE) ? push!(SCALE, GPUVector(texture_buffer(Point{2, Float32}[])))[] : SCALE[]
end
=#



visualize_default{T <: Real}(::Rectangle{T}, ::Style, kw_args=Dict()) = Dict(
    :primitive      => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :color          => RGBA(1f0, 0f0, 0f0, 1f0),
    :style          => Cint(4),
    :preferred_camera => :orthographic_pixel,
    :technique      => to_gl_technique(:square),
    :thickness      => 4f0
)
rectangle_position(r::Rectangle) = Point{2, Float32}(r.x, r.y)
rectangle_scale(r::Rectangle)    = Vec{2, Float32}(r.w, r.h)

visualize{T}(r::Rectangle{T}, s::Style, customizations=visualize_default(r.value, s)) = visualize(Input(r), s, customizations)
function visualize{T}(r::Signal{Rectangle{T}}, s::Style, customizations=visualize_default(r.value, s))
    @materialize! primitive = customizations

    data = merge(Dict(
        :position            => lift(rectangle_position, r),
        :scale               => lift(rectangle_scale, r),
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
