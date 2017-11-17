function sumlengths(points)
    T = eltype(points[1])
    result = zeros(T, length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        p1, p2 = points[i0], points[i]
        if !(any(map(isnan, p1)) || any(map(isnan, p2)))
            result[i] = result[i0] + norm(p1-p2)
        else
            result[i] = result[i0]
        end
    end
    result
end

intensity_convert(intensity, verts) = intensity
function intensity_convert(intensity::VecOrSignal{T}, verts) where T
    if length(value(intensity)) == length(value(verts))
        GLBuffer(intensity)
    else
        Texture(intensity)
    end
end


dist(a, b) = abs(a-b)
mindist(x, a, b) = min(dist(a, x), dist(b, x))
function gappy(x, ps)
    n = length(ps)
    x <= first(ps) && return first(ps) - x
    for j=1:(n-1)
        p0 = ps[j]
        p1 = ps[min(j+1, n)]
        if p0 <= x && p1 >= x
            return mindist(x, p0, p1) * (isodd(j) ? 1 : -1)
        end
    end
    return last(ps) - x
end
function ticks(points, resolution)
    Float16[gappy(x, points) for x = linspace(first(points),last(points), resolution)]
end


function _default(position::Union{VecTypes{T}, MatTypes{T}}, s::style"lines", data::Dict) where T<:Point
    pv = value(position)
    p_vec = if isa(position, GPUArray)
        position
    else
        const_lift(position) do p
            pvv = vec(p)
            if length(pvv) < 4 # geometryshader doesn't work with less then 4
                return [pvv..., fill(T(NaN), 4-length(pvv))...]
            else
                return pvv
            end
        end
    end

    @gen_defaults! data begin
        dims::Vec{2, Int32} = const_lift(position) do p
            sz = ndims(p) == 1 ? (length(p), 1) : size(p)
            Vec{2, Int32}(sz)
        end
        vertex              = p_vec => GLBuffer
        intensity           = nothing
        color_map           = nothing => Texture
        color_norm          = nothing
        color               = (color_map == nothing ? default(RGBA, s) : nothing) => GLBuffer
        thickness::Float32  = 2f0
        pattern             = nothing
        fxaa                = false
        preferred_camera    = :orthographic_pixel
        boundingbox         = const_lift(x-> GLBoundingBox(to_cpu_mem(x)), value(p_vec))
        indices             = const_lift(length, p_vec) => to_indices
        shader              = GLVisualizeShader("fragment_output.frag", "util.vert", "lines.vert", "lines.geom", "lines.frag")
        gl_primitive        = GL_LINE_STRIP_ADJACENCY
        startend            = const_lift(p_vec) do vec
            l = length(vec)
            map(1:l) do i
                (i == 1 || isnan(vec[max(i-1, 1)])) && return Float32(0) # start
                (i == l || isnan(vec[min(i+1, l)])) && return Float32(1) # end
                Float32(2) # segment
            end
        end => GLBuffer
    end
    if pattern != nothing
        if !isa(pattern, Texture)
            if !isa(pattern, Vector)
                error("Pattern needs to be a Vector of floats")
            end
            tex = GLAbstraction.Texture(ticks(pattern, 100), x_repeat = :repeat)
            data[:pattern] = tex
        end
        @gen_defaults! data begin
            pattern_length = Float32(last(pattern))
            lastlen   = const_lift(sumlengths, p_vec) => GLBuffer
            maxlength = const_lift(last, lastlen)
        end
    end
    data[:intensity] = intensity_convert(intensity, vertex)
    data
end

to_points(x::Vector{LineSegment{T}}) where {T} = reinterpret(T, x, (length(x)*2,))

_default(positions::VecTypes{LineSegment{T}}, s::Style, data::Dict) where {T <: Point} =
    _default(const_lift(to_points, positions), style"linesegment"(), data)

function _default(positions::VecTypes{T}, s::style"linesegment", data::Dict) where T <: Point
    @gen_defaults! data begin
        vertex              = positions           => GLBuffer
        color               = default(RGBA, s, 1) => GLBuffer
        thickness::Float32  = 2f0                 => GLBuffer
        shape               = RECTANGLE
        pattern             = nothing
        fxaa                = false
        indices             = const_lift(length, positions) => to_indices
        preferred_camera    = :orthographic_pixel
        # TODO update boundingbox
        boundingbox         = GLBoundingBox(to_cpu_mem(value(positions)))
        shader              = GLVisualizeShader("fragment_output.frag", "util.vert", "line_segment.vert", "line_segment.geom", "lines.frag")
        gl_primitive        = GL_LINES
    end
    if !isa(pattern, Texture) && pattern != nothing
        if !isa(pattern, Vector)
            error("Pattern needs to be a Vector of floats")
        end
        tex = GLAbstraction.Texture(ticks(pattern, 100), x_repeat = :repeat)
        data[:pattern] = tex
        data[:pattern_length] = Float32(last(pattern))
    end
    data
end

function _default(positions::Vector{T}, range::Range, s::style"lines", data::Dict) where T <: AbstractFloat
    length(positions) != length(range) && throw(
        DimensionMismatsch("length of $(typeof(positions)) $(length(positions)) and $(typeof(range)) $(length(range)) must match")
    )
    _default(points2f0(positions, range), s, data)
end



function _default(
        geometry::TOrSignal{G}, s::style"lines", data::Dict
    ) where G<:GeometryPrimitive{3}
    wireframe(geometry, data)
end
function _default(
        geometry::TOrSignal{GLNormalMesh}, s::style"lines", data::Dict
    )
    wireframe(geometry, data)
end
function wireframe(
        geometry, data::Dict
    )
    points = const_lift(geometry) do g
        decompose(Point3f0, g) # get the point representation of the geometry
    end
    # Get line index representation
    indices = decompose(Face{2, GLIndex}, value(geometry))
    data[:indices] = reinterpret(GLuint, indices)
    _default(points, style"linesegment"(), data)
end


struct GridPreRender end

function (::GridPreRender)()
    glEnable(GL_CULL_FACE)
    glDepthMask(GL_FALSE)
    glCullFace(GL_BACK)
end

function _default(c::TOrSignal{T}, ::Style{:grid}, data) where T<:AABB
    @gen_defaults! data begin
        primitive::GLPlainMesh = c
        bg_color = RGBA{Float32}(0.99,0.99,0.99,1)
        grid_color = RGBA{Float32}(0.8,0.8,0.8,1)
        grid_thickness = Vec3f0(0.999)
        gridsteps = Vec3f0(5)
        shader = GLVisualizeShader("fragment_output.frag", "grid.vert", "grid.frag")
        boundingbox = c
        prerender = GridPreRender()
        postrender = () -> glDisable(GL_CULL_FACE);
    end
end


function line_indices(array)
    len = length(array)
    result = Array(GLuint, len*2)
    idx = 1
    for i=0:(len-3), j=0:1
        result[idx] = i+j
        idx += 1
    end
    result
    #GLuint[i+j for i=0:(len-3) for j=0:1] # on 0.5
end
"""
Fast, non anti aliased lines
"""
function _default(position::VecTypes{T}, s::style"speedlines", data::Dict) where T <: Point
    @gen_defaults! data begin
        vertex       = position => GLBuffer
        color_map    = nothing  => Vec2f0
        indices      = const_lift(line_indices, position) => to_indices
        color        = (color_map == nothing ? default(RGBA{Float32}, s) : nothing) => GLBuffer
        color_norm   = nothing  => Vec2f0
        intensity    = nothing  => GLBuffer
        shader       = GLVisualizeShader("fragment_output.frag", "dots.vert", "dots.frag")
        gl_primitive = GL_LINES
    end
end
