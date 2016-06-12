function sumlengths(points)
    result = zeros(eltype(points[1]), length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        result[i] = result[i0] + norm(points[i0]-points[i])
    end
    result
end


function _default{T<:Point}(position::Union{VecTypes{T}, MatTypes{T}}, s::style"lines", data::Dict)
    pv = value(position)
    p_vec = const_lift(vec, position)
    @gen_defaults! data begin
        dims::Vec{2, Int32} = ndims(pv) == 1 ? (length(pv), 1) : size(pv)
        dotted              = false
        vertex              = p_vec  => GLBuffer
        color               = default(RGBA, s, 1) => GLBuffer
        stroke_color        = default(RGBA, s, 2) => GLBuffer
        thickness           = 1f0
        shape               = RECTANGLE
        transparent_picking = false
        is_fully_opaque     = false
        preferred_camera    = :orthographic_pixel
        max_primitives      = const_lift(length, p_vec)
        boundingbox         = GLBoundingBox(to_cpu_mem(value(p_vec)))
        indices             = const_lift(length, p_vec) => to_indices
        shader              = GLVisualizeShader("fragment_output.frag", "util.vert", "lines.vert", "lines.geom", "lines.frag")
        gl_primitive        = GL_LINE_STRIP_ADJACENCY
    end
    if dotted
        @gen_defaults! data begin
            lastlen   = const_lift(sumlengths, p_vec) => GLBuffer
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
        shader              = GLVisualizeShader("fragment_output.frag", "util.vert", "line_segment.vert", "line_segment.geom", "lines.frag")
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
    indices = decompose(Face{2, GLuint, -1}, value(geometry))
    data[:indices] = reinterpret(GLuint, indices)
    _default(points, style"linesegment"(), data)
end


immutable GridPreRender end

function call(::GridPreRender)
    glEnable(GL_CULL_FACE)
    glCullFace(GL_BACK)
end

function _default{T<:AABB}(c::TOrSignal{T}, ::Style{:grid}, data)
    @gen_defaults! data begin
        primitive::GLPlainMesh = c
        bg_color = RGBA{Float32}(1,1,1,0)
        grid_color = RGBA{Float32}(0.8,0.8,0.8,1)
        grid_thickness = Vec3f0(0.999)
        gridsteps = Vec3f0(5)
        is_fully_opaque     = false
        shader = GLVisualizeShader("fragment_output.frag", "grid.vert", "grid.frag")
        boundingbox = c
        prerender = GridPreRender()
        postrender = () -> (
            glEnable(GL_CULL_FACE);
            glCullFace(GL_BACK)
        )
    end
end
