immutable GLPoints end # only for dispatch 

typealias P_Primitive       Union{Mesh, GLPoints, Sprite, Vector{Sprite}}
typealias P_Position{N, T}  Union{Vector{Point{N, T}}, Grid, Cube}
typealias P_Scale           Union{Vector{Vec{N, T}}, Vec{N, T}}
typealias P_Rotation        Union{Q.Quaternion, Vector{Q.Quaternion}, Nothing} # rotation is optional (nothing)
typealias P_Color           Union{Vector{Colorant}, Colorant}

type Particle{PR <: Mesh, POS, SCALE, ROT, C}
    primitive::PR
    position ::POS
    scale    ::SCALE
    rotation ::ROT
    color    ::C
end



function visualize_default{T}(grid::MatTypes{T}, ::Style, kw_args=Dict())
    grid_min = get!(kw_args, :grid_min, Vec2f0(-1, -1))
    grid_max = get!(kw_args, :grid_max, Vec2f0( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3f0((1f0 / Vec2f0(size(grid))), 1f0) .* Vec3f0(grid_length, 1f0)
    p = GLNormalMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1.0)))
    n = Vec2f0(minimum(grid), maximum(grid))
    return Dict(
        :primitive  => p,
        :color      => default(Vector{RGBA}),
        :scale      => scale,
        :color_norm => n
    )
end

function visualize{T <: AbstractFloat}(grid::Texture{T, 2}, s::Style, customizations=visualize_default(grid, s))
    @materialize grid_min, grid_max, color_norm = customizations
    data[:y_scale] = grid
    assemble_instanced(
        grid, data,
        "util.vert", "meshgrid.vert", "standard.frag",
        boundingbox=const_lift(particle_grid_bb, grid_min, grid_max, color_norm)
    )
end
