
typealias P_Primitive                      Union{VecTypes{Sprite}, AbstractMesh, GLPoints, DistanceField, Sprite}
typealias P_Position{T <: Point}           Union{VecTypes{T}, Grid, Cube, Void}
typealias P_Scale{N,T}                     Union{VecTypes{Vec{N, T}}, Vec{N, T}, T, Void}
typealias P_Rotation{T <: Quaternion}      Union{VecTypes{T}, T, Void} # rotation is optional (nothing)
typealias P_Color{T <: Colorant}           Union{VecTypes{T}, T, Void}
typealias P_Intensitiy{T <: AbstractFloat} Union{VecTypes{T}, T, Void}





function Particles(data::Dict)
    @gen_defaults! data begin
        primitive   = GLPoints()
        position    = Grid(-1:1, -1:1)
        scale       = nothing
        rotation    = nothing
        color       = nothing
        intensity   = nothing
        color_norm  = nothing
    end
    Particles([data[key] for key in fieldnames(Particles)]...)
end

visualize{T<:Number}(p::MatTypes{T}, s::Style, data::Dict) = visualize((p, Grid(linspace(-1,1,size(p,1)), linspace(-1,1,size(p,1)))), s, data)
visualize{T<:Number}(p::Tuple{MatTypes{T}, Grid}, s::Style, data::Dict) = _visualize(
    Particles(scale=(data[:scale_x], data[:scale_y], p[1]), position=p[2]),
    s, data
)


function visualize{T<:Point}(p::VecTypes{T}, s::Style, data::Dict)
    data[:position] = p
    _visualize(Particles(data), s, data)
end
function visualize(p::Tuple{P_Position, P_Primitive}, s::Style, data::Dict)
    data[:position], data[:primitive] = p
    _visualize(Particles(data), s, data)
end

_visualize{P <: AbstractMesh}(p::Particles{P}, s::Style, data::Dict) = assemble_shader(
    p, data,
    "util.vert", "Particles.vert", "standard.frag",
)

_visualize{P <: GLPoints}(p::Particles{P}, s::Style, data::Dict) = assemble_shader(
    p, data,
    "dots.vert", "dots.frag"
)



function _visualize{P <: DistanceField}(p::Particles{P}, s::Style, data::Dict)
    robj = assemble_shader(
        p, data,
        "util.vert", "Particles.vert", "distance_shape.frag",
    )
    empty!(robj.prerenderfunctions)
    prerender!(robj,
        glDisable, GL_DEPTH_TEST,
        glDepthMask, GL_FALSE,
        glDisable, GL_CULL_FACE,
        enabletransparency
    )
    robj
end

function assemble_shader(p::Particles, data, shaderpaths...)
    bb = AABB{Float32}(p)
    data = merge(data, [key => gl_convert(p.(key)) for key in fieldnames(Particles)])
    assemble_shader(p, data, bb, shaderpaths...)
end
function assemble_shader(main, data, boundingbox, shaderpaths...; primitive=GL_TRIANGLES)
    program = GLVisualizeShader(shaders..., attributes=dict)
    renderobject(main, data, program, boundingbox, primitive)
end

const NeedsInstancing = Union{Particles}
function renderobject(main::NeedsInstancing, data, program, boundingbox, primitive)
    instanced_renderobject(data, program, boundingbox, primitive, main)
end
function renderobject(main::NeedsInstancing, data, program, boundingbox, primitive)
    std_renderobject(data, program, boundingbox, primitive, main)
end
