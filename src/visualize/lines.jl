function _default{T<:Point}(position::Union{VecTypes{T}, MatTypes{T}}, s::style"lines", data::Dict)
    pv = value(position)
    if isa(position, GPUArray)
        p_vec = position
    else
        p_vec = const_lift(vec, position)
    end
    @gen_defaults! data begin
        dims::Vec{2, Int32} = ndims(pv) == 1 ? (length(pv), 1) : size(pv)
        dotted              = false
        position            = p_vec
        color               = default(RGBA, s, 1)
        stroke_color        = default(RGBA, s, 2)
        thickness           = 1f0
        shape               = RECTANGLE
        boundingbox         = GLBoundingBox(to_cpu_mem(value(p_vec)))
        indices             = const_lift(length, p_vec) => to_indices
    end
    data
end

to_points{T}(x::Vector{LineSegment{T}}) = reinterpret(T, x, (length(x)*2,))

_default{T <: Point}(positions::VecTypes{LineSegment{T}}, s::Style, data::Dict) =
    _default(const_lift(to_points, positions), style"linesegment"(), data)

function _default{T <: Point}(positions::VecTypes{T}, s::style"linesegment", data::Dict)
    @gen_defaults! data begin
        dotted              = false
        position            = positions
        color               = default(RGBA, s, 1)
        thickness           = 2f0
        shape               = RECTANGLE
        indices             = const_lift(length, positions) => to_indices
        boundingbox         = GLBoundingBox(to_cpu_mem(value(positions)))
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

@compat function (::GridPreRender)()
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
        is_fully_opaque = false
        shader = GLVisualizeShader("fragment_output.frag", "grid.vert", "grid.frag")
        boundingbox = c
        prerender = GridPreRender()
        postrender = () -> (
            glDisable(GL_CULL_FACE);
        )
    end
end
