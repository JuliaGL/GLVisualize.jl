visualize_default{T <: Real}(::Union(Texture{Point2{T}, 1}, Vector{Point2{T}}), ::Style, kw_args=Dict()) = @compat(Dict(
    :primitive          => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :color              => RGBA(1f0, 0f0, 0f0, 1f0),
    :scale              => Vec2(50, 50),
    :technique          => :circle,
    :preferred_camera   => :orthographic_pixel
))

visualize(locations::Vector{Point2{Float32}}, s::Style, customizations=visualize_default(locations, s)) = 
    visualize(texture_buffer(locations), s, customizations)


function visualize{T <: Real}(
        positions::Texture{Point2{T}, 1}, 
        s::Style, customizations=visualize_default(positions, s)
    )
    @materialize! primitive, technique = customizations
    data = merge(@compat(Dict(
        :positions           => positions,
        :technique           => lift(to_gl_technique, technique)
    )), collect_for_gl(primitive), customizations)

    program = TemplateProgram(
        File(shaderdir, "util.vert"), 
        File(shaderdir, "particles2D.vert"), 
        File(shaderdir, "distance_shape.frag"),
        attributes=data,
        fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")]
    )
    instanced_renderobject(data, length(positions), program)
end

#=
begin 
local const POSITIONS = GPUVector{Point2{Float32}}[]
local const SCALE     = GPUVector{Vector2{Float32}}[]
getposition()   = isempty(POSITIONS) ? push!(POSITIONS, GPUVector(texture_buffer(Point2{Float32}[])))[] : POSITIONS[]
getscale()      = isempty(SCALE) ? push!(SCALE, GPUVector(texture_buffer(Point2{Float32}[])))[] : SCALE[]
end 
=#



visualize_default{T <: Real}(::Rectangle{T}, ::Style, kw_args=Dict()) = Dict(
    :primitive      => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :color          => RGBA(1f0, 0f0, 0f0, 1f0),
    :style          => Cint(4),
    :technique      => to_gl_technique(:square)
)
rectangle_position(r::Rectangle) = Point2{Float32}(r.x, r.y)
rectangle_scale(r::Rectangle)    = Vector2{Float32}(r.w, r.h)

function visualize{T}(r::Signal{Rectangle{T}}, s::Style, customizations=visualize_default(r.value, s))
    @materialize! primitive = customizations

    data = merge(Dict(
        :position            => lift(rectangle_position, r),
        :scale               => lift(rectangle_scale, r),
    ), collect_for_gl(primitive), customizations)
    program = TemplateProgram(
        File(shaderdir, "particles2D_single.vert"), 
        File(shaderdir, "distance_shape.frag"),
        attributes=data,
        fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")]
    )
    robj = RenderObject(data, program)
    prerender!(robj, 
        glDisable, GL_DEPTH_TEST, 
        glDepthMask, GL_FALSE,
        glDisable, GL_CULL_FACE,
        enabletransparency)
    postrender!(robj, 
        render, robj.vertexarray)
    robj
end