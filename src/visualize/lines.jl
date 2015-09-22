visualize_default{T <: Real}(::Union{Texture{Point{2, T}, 1}, Vector{Point{2, T}}}, ::Style{:lines}, kw_args=Dict()) = Dict(
    :shape                  => RECTANGLE,
    :style                  => Cint(FILLED),
    :transparent_picking    => false,
    :preferred_camera       => :orthographic_pixel,
    :color                  => RGBA(1f0, 0f0, 0f0, 1f0),
    :thickness              => 4f0
)

function visualize(locations::Signal{Vector{Point{2, Float32}}}, s::Style{:lines}, customizations=visualize_default(locations.value,s))
    start_val = GLBuffer(locations.value)
    lift(update!, start_val, locations)
    visualize(start_val, s, customizations)
end

function lastlen(points)
    result = zeros(eltype(points), length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        result[i] = result[i0] + norm(points[i0]-points[i])
    end
    result
end
function visualize{T}(positions::GLBuffer{Point{2, T}}, s::Style{:lines}, data=visualize_default(locations.value,s))
    ps = gpu_data(positions)
    ll = lastlen(ps)
    data[:vertex]    = positions
    data[:lastlen]   = GLBuffer(ll)
    data[:maxlength] = last(ll)

    program = GLVisualizeShader("lines.vert", "lines.geom", "lines.frag")
    std_renderobject( 
        data, program,
        Input(AABB{Float32}(ps)), GL_LINE_STRIP_ADJACENCY 
    )
end
