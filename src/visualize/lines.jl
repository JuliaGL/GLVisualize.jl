visualize_default{T <: Real}(::Union{Texture{Point{2, T}, 1}, Vector{Point{2, T}}}, ::Style{:lines}, kw_args=Dict()) = Dict(
    :shape                  => Cint(RECTANGLE),
    :style                  => Cint(FILLED),
    :transparent_picking    => false,
    :preferred_camera       => :orthographic_pixel,
    :color                  => RGBA(1f0, 0f0, 0f0, 1f0),
    :thickness              => 4f0,
    :dotted                 => false
)

function visualize(locations::Signal{Vector{Point{2, Float32}}}, s::Style{:lines}, customizations=visualize_default(locations.value,s))
    ll = const_lift(lastlen, locations)
    maxlength = const_lift(last, ll)

    start_valp = GLBuffer(locations.value)
    start_vall = GLBuffer(ll.value)
    const_lift(update!, start_valp, locations)
    const_lift(update!, start_vall, ll)
    visualize(start_valp, start_vall, maxlength, s, customizations)
end

function lastlen(points)
    result = zeros(eltype(points[1]), length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        result[i] = result[i0] + norm(points[i0]-points[i])
    end
    result
end
function visualize{T}(positions::GLBuffer{Point{2, T}}, ll::GLBuffer{T}, maxlength, s::Style{:lines}, data=visualize_default(locations.value,s))
    ps = gpu_data(positions)
    data[:vertex]    = positions
    data[:lastlen]   = ll
    data[:maxlength] = maxlength

    program = GLVisualizeShader("util.vert", "lines.vert", "lines.geom", "lines.frag", attributes=data)
    std_renderobject( 
        data, program,
        Input(AABB{Float32}(ps)), GL_LINE_STRIP_ADJACENCY 
    )
end
