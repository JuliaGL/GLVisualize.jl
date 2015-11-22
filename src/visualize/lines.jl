function lastlen(points)
    result = zeros(eltype(points[1]), length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        result[i] = result[i0] + norm(points[i0]-points[i])
    end
    result
end

function _default{N,T}(position::VecTypes{Point{N,T}}, s::style"lines", data::Dict)
    @gen_defaults! data begin
        dotted              = false
        vertex              = position               => GLBuffer
        color               = default(RGBA, s, 1)    => GLBuffer
        stroke_color        = default(RGBA, s, 2)    => GLBuffer
        thickness           = 2f0
        shape               = RECTANGLE
        style               = FILLED
        transparent_picking = false
        preferred_camera    = :orthographic_pixel
        max_primitives      = length(position)-4
        boundingbox         = GLBoundingBox(position)
        shader              = GLVisualizeShader("util.vert", "lines.vert", "lines.geom", "lines.frag")
        gl_primitive        = GL_LINE_STRIP_ADJACENCY
    end
    if data[:dotted]
        @gen_defaults! data begin
            lastlen   = const_lift(lastlen, x) => GLBuffer
            maxlength = const_lift(last, ll)
        end
    end
    data
end


function _default{T <: AbstractFloat}(positions::Vector{T}, range::Range, s::style"lines", data::Dict)
    length(positions) != length(range) && throw(
        DimensionMismatsch("length of $(typeof(positions)) $(length(positions)) and $(typeof(range)) $(length(range)) must match")
    )
    _default(points2f0(positions, range), s, data)
end


#Parametric rendering of arbitrary opengl functions
_default(func::Shader, s::Style, data::Dict) = @gen_defaults! data begin
    primitive:: GLUVMesh2D  = SimpleRectangle{Float32}(0f0,0f0,1f0,1f0)
    color                   = default(RGBA, s)
    boundingbox             = GLBoundingBox(primitive)
    preferred_camera        = :orthographic_pixel
    shader                  = GLVisualizeShader("parametric.vert", "parametric.frag"; view = Dict("function" => bytestring(func.source)))
end
