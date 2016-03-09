function sumlengths(points)
    result = zeros(eltype(points[1]), length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        result[i] = result[i0] + norm(points[i0]-points[i])
    end
    result
end

"""
Converts index arrays to the OpenGL equivalent.
"""
to_indices(x::TOrSignal{Int}) = x
to_indices(x::VecOrSignal{UnitRange{Int}}) = x
"""
For integers, we transform it to 0 based indices
"""
to_indices{I<:Integer}(x::Vector{I}) = indexbuffer(map(i-> Cuint(i-1), x))
function to_indices{I<:Integer}(x::Signal{Vector{I}})
    x = map(x-> map(i->Cuint(i-1),x), x)
    gpu_mem = GLBuffer(value(x), buffertype = GL_ELEMENT_ARRAY_BUFFER)
    preserve(const_lift(update!, gpu_mem, x))
    gpu_mem
end
"""
If already GLuint, we assume its 0 based (bad heuristic, should better be solved with some Index type)
"""
to_indices{I<:GLuint}(x::Vector{I}) = indexbuffer(x)
to_indices{I<:GLuint}(x::Signal{Vector{I}}) = indexbuffer(x)
to_indices(x) = error(
    "Not a valid index type: $x.
    Please choose from Int, Vector{UnitRange{Int}}, Vector{Int} or a signal of either of them"
)


function _default{N,T}(position::VecTypes{Point{N,T}}, s::style"lines", data::Dict)
    @gen_defaults! data begin
        dotted              = false
        vertex              = position            => GLBuffer
        color               = default(RGBA, s, 1) => GLBuffer
        stroke_color        = default(RGBA, s, 2) => GLBuffer
        thickness           = 2f0
        shape               = RECTANGLE
        transparent_picking = false
        preferred_camera    = :orthographic_pixel
        max_primitives      = const_lift(length, position)
        boundingbox         = GLBoundingBox(to_cpu_mem(value(position)))
        indices             = const_lift(length, position) => to_indices
        shader              = GLVisualizeShader("util.vert", "lines.vert", "lines.geom", "lines.frag")
        gl_primitive        = GL_LINE_STRIP_ADJACENCY
    end
    if dotted
        @gen_defaults! data begin
            lastlen   = const_lift(sumlengths, position) => GLBuffer
            maxlength = const_lift(last, ll)
        end
    end
    data
end

to_points{T}(x::Vector{LineSegment{T}}) = reinterpret(T, x, (length(x)*2,))

_default{T <: Point}(positions::VecTypes{LineSegment{T}}, s::Style, data::Dict) =
    _default(const_lift(to_points, positions), style"linesegment"(), data)

function _default{T <: Point}(positions::VecTypes{T}, s::style"linesegment", data::Dict)
    @gen_defaults! data begin
        dotted              = false
        vertex              = positions           => GLBuffer
        color               = default(RGBA, s, 1) => GLBuffer
        thickness           = 2f0                 => GLBuffer
        shape               = RECTANGLE
        transparent_picking = false
        indices             = const_lift(length, positions) => to_indices
        preferred_camera    = :orthographic_pixel
        boundingbox         = GLBoundingBox(to_cpu_mem(value(positions)))
        shader              = GLVisualizeShader("util.vert", "line_segment.vert", "line_segment.geom", "lines.frag")
        gl_primitive        = GL_LINES
    end
end

function _default{T <: AbstractFloat}(positions::Vector{T}, range::Range, s::style"lines", data::Dict)
    length(positions) != length(range) && throw(
        DimensionMismatsch("length of $(typeof(positions)) $(length(positions)) and $(typeof(range)) $(length(range)) must match")
    )
    _default(points2f0(positions, range), s, data)
end



function _default{G<:GeometryPrimitive{3}}(
        geometry::TOrSignal{G}, s::style"lines", data::Dict
    )
    points = const_lift(geometry) do g
         decompose(Point3f0, g) # get the point representation of the geometry
    end
    # Get line index representation
    indices = decompose(Face{2, GLuint, -1}, value(geometry))
    data[:indices] = reinterpret(GLuint, indices)
    _default(points, style"linesegment"(), data)
end
