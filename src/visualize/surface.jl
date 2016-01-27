
function surfboundingbox(position_x, position_y, position_z)
    arr = const_lift(StructOfArrays, Point3f0, position_x, position_y, position_z)
    map(AABB{Float32}, arr)
end
function surfboundingbox(grid, position_z)
    arr = const_lift(GridZRepeat, grid, position_z)
    map(AABB{Float32}, arr)
end

function _default{T <: AbstractFloat}(main::Tuple{MatTypes{T}, MatTypes{T}, MatTypes{T}}, s::Style{:surface}, data::Dict)
    @gen_defaults! data begin
        position_x  = main[1] => Texture
        position_y  = main[2] => Texture
        position_z  = main[3] => Texture
        boundingbox = surfboundingbox(position_x, position_y, position_z)
        scale       = Vec3f0(0)
    end
    surface(position_z, s, data)
end


_default{T <: AbstractFloat}(main::MatTypes{T}, s::Style{:surface}, data::Dict) = _default((Grid(value(main), ((-1f0, 1f0), (-1f0, 1f0))), main), s, data)
function _default{G <: Grid{2}, T <: AbstractFloat}(main::Tuple{G, MatTypes{T}}, s::Style{:surface}, data::Dict)
    @gen_defaults! data begin
        position    = main[1]
        position_z  = main[2] => Texture
        boundingbox = surfboundingbox(position, position_z)
        scale       = Vec3f0(step(main[1].dims[1]), step(main[1].dims[2]), 1)
    end
    surface(position_z, s, data)
end
_extrema(x::AABB) = Vec2f0(minimum(x)[3], maximum(x)[3])
nothing_or_vec(x) = x
nothing_or_vec(x::Array) = vec(x)
function surface(main, s::Style{:surface}, data::Dict)
    @gen_defaults! data begin
        primitive::GLMesh2D = SimpleRectangle(0f0,0f0,1f0,1f0)
        scale      = nothing
        position   = nothing
        position_x = nothing => Texture
        position_y = nothing => Texture
        position_z = nothing => Texture
        boundingbox= nothing
    end
    @gen_defaults! data begin
        color       = default(Vector{RGBA}, s) => Texture
        color_norm  = const_lift(_extrema, boundingbox)
        instances   = const_lift(length, main)

        shader     = GLVisualizeShader(
            "util.vert", "surface.vert", "standard.frag",
            view=Dict("lol_intel"=>lol_intel(position))
        )
    end
end
