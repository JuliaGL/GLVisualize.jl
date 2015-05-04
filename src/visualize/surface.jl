Base.minimum(t::Texture) = minimum(gpu_data(t))
Base.maximum(t::Texture) = maximum(gpu_data(t))

function visualize_default(grid::Union(Texture{Float32, 2}, Matrix{Float32}), ::Style{:surface}, kw_args...) 
    grid_min    = get(kw_args[1], :grid_min, Vec2(-1, -1))
    grid_max    = get(kw_args[1], :grid_max, Vec2( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3((1f0 ./[size(grid)...])..., 1f0)
    @compat(Dict(
        :primitive  => GLMesh2D(Rectangle(0f0,0f0,1f0,1f0)),
        :color_ramp => RGBAU8[rgbaU8(1,0,0,1), rgbaU8(1,1,0,1), rgbaU8(0,1,0,1), rgbaU8(0,1,1,1), rgbaU8(0,0,1,1)],
        :grid_min   => grid_min,
        :grid_max   => grid_max,
        :color_norm => Vec2(minimum(grid), maximum(grid)), 
        :scale      => scale .* Vec3(grid_length..., 1f0)
    ))
end


function visualize(grid::Texture{Float32, 2}, s::Style{:surface}, customizations=visualize_defaults(grid, s))
    @materialize! screen, color_ramp, primitive, model = customizations
    @materialize grid_min, grid_max, color_norm = customizations
    camera       = screen.perspectivecam
    data = merge(@compat(Dict(
        :z              => grid,
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :viewmodel      => lift(*, camera.view, model),
    )), collect_for_gl(primitive), customizations)

    bb = lift(particle_grid_bb, grid_min, grid_max, color_norm) # This is not accurate. color_norm doesn't need to reflect the real height. also it doesn't get recalculated when the texture changes.

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "surface.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(grid), program, bb)
end



#Surface from x,y,z matrices

visualize{T <: Matrix{Float32}}(x::T, y::T, z::T, style=:default; kw_args...) = visualize(x,y,z, Style{style}(), visualize_default(z, style, kw_args))


#Can't be handled by the @gen_visualize macro
function visualize{T <: Input{Matrix{Float32}}}(x::T, y::T, z::T, s::Style{:surface}, customizations=visualize_defaults(z.value, s))
    xt, yt, zt = Texture(x.value), Texture(y.value), Texture(z.value)
    lift(update!, xt, x); lift(update!, yt, y); lift(update!, yt, y)
    visualize(xt, yt, zt, s, customizations)
end
visualize{T <: Matrix{Float32}}(x::T, y::T, z::T, s::Style{:surface}, customizations=visualize_defaults(z, s)) = 
    visualize(Texture(x),Texture(y), Texture(z), s, customizations)

function visualize{T <: Texture{Float32, 2}}(x::T, y::T, z::T, s::Style{:surface}, customizations=visualize_defaults(z, s))
    @materialize! screen, color_ramp, primitive, model = customizations
    camera       = screen.perspectivecam
    data = merge(@compat(Dict(
        :x              => x,
        :y              => y,
        :z              => z,
        :color_ramp     => Texture(color_ramp),

        :projection     => camera.projection,
        :viewmodel      => lift(*, camera.view, model),
    )), collect_for_gl(primitive), customizations)

    min_x, min_y, min_z = minimum(x), minimum(y), minimum(z)
    max_x, max_y, max_z = maximum(x), maximum(y), maximum(z)

    bb = lift(AABB, min_x, min_y, min_z, max_x, max_y, max_z) # This is not accurate as I'm not recalcuting the data when something updates

    program = TemplateProgram(File(shaderdir, "util.vert"), File(shaderdir, "surface2.vert"), File(shaderdir, "standard.frag"))
    instanced_renderobject(data, length(x), program, bb)
end
