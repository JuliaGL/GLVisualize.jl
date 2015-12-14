function _default{T <: AbstractFloat}(main::Tuple{MatTypes{T}, MatTypes{T}, MatTypes{T}}, s::Style{:surface}, data::Dict)
    @gen_defaults! data begin
        position_x = main[1] => Texture
        position_y = main[2] => Texture
        position_z = main[3] => Texture
        scale      = Vec3f0(0)
    end
    surface(position_z, s, data)
end


_default{T <: AbstractFloat}(main::MatTypes{T}, s::Style{:surface}, data::Dict) = _default((Grid(value(main)), main), s, data)
function _default{G <: Grid{2}, T <: AbstractFloat}(main::Tuple{G, MatTypes{T}}, s::Style{:surface}, data::Dict)
    @gen_defaults! data begin
        position   = main[1]
        position_z = main[2] => Texture
        scale      = Vec3f0(step(main[1].dims[1]), step(main[1].dims[2]), 1)
    end
    surface(position_z, s, data)
end
function surface(main, s::Style{:surface}, data::Dict)
    @gen_defaults! data begin
        position   = nothing
        position_x = nothing
        position_y = nothing
        position_z = nothing
        primitive::GLMesh2D = SimpleRectangle(0f0,0f0,1f0,1f0)
        color      = default(Vector{RGBA}, s) => Texture
        color_norm = Vec2f0(minimum(main), maximum(main))
        instances  = length(main)
        shader     = GLVisualizeShader("util.vert", "surface.vert", "standard.frag")
    end
end
