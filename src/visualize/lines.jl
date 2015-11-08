function _default{T <: Point{2}}(x::VecTypes{T}, s::style"lines", kw_args=Dict())
    dotted = get!(kw_args, :dotted, false)
    if dotted
        ll = const_lift(lastlen, locations)
        kw_args[maxlength] = const_lift(last, ll)
        kw_args[lastlen]  = gl_convert(GLBuffer, ll)
    end
    Dict(
        :shape               => RECTANGLE,
        :style               => FILLED,
        :transparent_picking => false,
        :preferred_camera    => :orthographic_pixel,
        :color               => default(RGBA, s),
        :thickness           => 2f0,
    )
end
function lastlen(points)
    result = zeros(eltype(points[1]), length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        result[i] = result[i0] + norm(points[i0]-points[i])
    end
    result
end

function visualize{T <: Point{2}}(locations::Signal{Vector{T}}, s::style"lines", data)
    if dotted
        ll = const_lift(lastlen, locations)
        data[maxlength] = const_lift(last, ll)
        data[lastlen]  = gl_convert(GLBuffer, ll)
    end
    visualize(gl_convert(GLBuffer, locations), s, data)
end


function visualize{T <: AbstractFloat}(positions::Vector{T}, range::Range, s::Style{:lines}, data)
    length(positions) != length(range) && throw(
        DimensionMismatsch("length of $(typeof(positions)) $(length(positions)) and $(typeof(range)) $(length(range)) must match")
    )
    visualize(points2f0(positions, range), s, data)
end


function visualize{T <: Point{2}}(positions::GLBuffer{T}, s::Style{:lines}, data)
    ps = gpu_data(positions)
    data[:vertex]    = positions
    data[:lastlen]   = ll
    data[:maxlength] = maxlength
    data[:max_primitives] = Cint(length(positions)-4)

    program = GLVisualizeShader("util.vert", "lines.vert", "lines.geom", "lines.frag", attributes=data)
    std_renderobject(
        data, program,
        Signal(AABB{Float32}(ps)), GL_LINE_STRIP_ADJACENCY
    )
end
