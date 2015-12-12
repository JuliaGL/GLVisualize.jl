visualize{T <: AbstractFloat}(t::Tuple{MatTypes{T}, Range, Range}, style) = visualize((t[1], Grid(t[2], t[3])), style)


function _default{T <: AbstractFloat}(main::MatTypes{T}, s::Style{:surface}, data::Dict)
    grid = Grid(value(main))
    @gen_defaults! data begin
        z          = main => Texture
        position   = grid
        primitive::GLMesh2D = SimpleRectangle(0f0,0f0,1f0,1f0)
        color      = default(Vector{RGBA}, s) => Texture
        color_norm = Vec2f0(minimum(main), maximum(main))
        scale      = Vec3f0(step(grid.dims[1]), step(grid.dims[2]), 1)
        instances  = length(main)
        shader     = GLVisualizeShader("util.vert", "surface.vert", "standard.frag")
    end
end
