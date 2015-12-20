Base.minimum(t::Texture) = minimum(gpu_data(t))
Base.maximum(t::Texture) = maximum(gpu_data(t))

function visualize_default(grid::Union{Texture{Float32, 2}, Matrix{Float32}}, s::Style{:surface}, kw_args=Dict())
    grid_min    = get(kw_args, :grid_min, Vec2f0(-1, -1))
    grid_max    = get(kw_args, :grid_max, Vec2f0( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3f0((1f0 ./[size(grid)...])..., 1f0)
    Dict(
        :primitive  => GLMesh2D(SimpleRectangle(0f0,0f0,1f0,1f0)),
        :color      => default(Vector{RGBA},s),
        :grid_min   => grid_min,
        :grid_max   => grid_max,
        :color_norm => Vec2f0(minimum(grid), maximum(grid)),
        :scale      => scale .* Vec3f0(grid_length..., 1f0)
    )
end


function visualize(grid::Texture{Float32, 2}, s::Style{:surface}, customizations=visualize_default(grid, s))
    @materialize! color, primitive = customizations
    @materialize grid_min, grid_max, color_norm = customizations
    data = merge(Dict(
        :z              => grid,
        :color          => Texture(color),
    ), collect_for_gl(primitive), customizations)

    bb = const_lift(particle_grid_bb, grid_min, grid_max, color_norm) # This is not accurate. color_norm doesn't need to reflect the real height. also it doesn't get recalculated when the texture changes.

    assemble_instanced(
        grid, data,
        "util.vert", "surface.vert", "standard.frag",
        boundingbox=bb
    )
end


#Surface from x,y,z matrices

visualize{T <: Matrix{Float32}}(x::T, y::T, z::T, style=:default; kw_args...) = visualize(x,y,z, Style{style}(), visualize_default(z, style, kw_args))
visualize{T <: Signal{Matrix{Float32}}}(x::T, y::T, z::T, style=:default; kw_args...) = visualize(x,y,z, Style{style}(), visualize_default(value(z), style, kw_args))


#Can't be handled by the @gen_visualize macro
function visualize{T <: Signal{Matrix{Float32}}}(x::T, y::T, z::T, s::Style{:surface}, customizations=visualize_default(z.value, s))
    xt, yt, zt = Texture(x.value), Texture(y.value), Texture(z.value)
    preserve(const_lift(update!, xt, x))
    preserve(const_lift(update!, yt, y))
    preserve(const_lift(update!, yt, y))
    visualize(xt, yt, zt, s, customizations)
end
visualize{T <: Matrix{Float32}}(x::T, y::T, z::T, s::Style{:surface}, customizations=visualize_default(z, s)) =
    visualize(Texture(x),Texture(y), Texture(z), s, customizations)

function visualize{T <: Texture{Float32, 2}}(x::T, y::T, z::T, s::Style{:surface}, customizations=visualize_default(z, s))
    @materialize! color, primitive = customizations
    data = merge(Dict(
        :x              => x,
        :y              => y,
        :z              => z,
        :color          => Texture(color)
    ), collect_for_gl(primitive), customizations)

    min_x, min_y, min_z = minimum(x), minimum(y), minimum(z)
    max_x, max_y, max_z = maximum(x), maximum(y), maximum(z)

    bb = const_lift(AABB{Float32}, min_x, min_y, min_z, max_x, max_y, max_z) # This is not accurate as I'm not recalcuting the data when something updates

    program = assemble_instanced(
        x, data,
        "util.vert", "surface2.vert", "standard.frag",
        boundingbox=bb
    )
end
