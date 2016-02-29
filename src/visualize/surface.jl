
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

function _default{T <: AbstractFloat}(main::MatTypes{T}, s::Style{:surface}, data::Dict)
    @gen_defaults! data begin
        ranges = ((-1f0, 1f0), (-1f0,1f0))
    end
    delete!(data, :ranges)
    _default((Grid(value(main), value(ranges)), main), s, data)
end
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
        color       = nothing
        color_map   = (color==nothing ? default(Vector{RGBA}, s) : nothing) => Texture
        color_norm  = (color==nothing ? const_lift(_extrema, boundingbox) : nothing)
        instances   = const_lift(length, main)

        shader     = GLVisualizeShader(
            "util.vert", "surface.vert", "standard.frag",
            view=Dict("position_calc"=>position_calc(position, position_x, position_y, position_z, Texture))
        )
    end
end

function position_calc(x...)
    _position_calc(filter(x->!isa(x, Void), x)...)
end
function glsllinspace(position::Grid, gi, index)
    """
    (((float(position.dims[$gi])-($(index)+1)) *
        position.minimum[$gi] + $(index)*position.maximum[$gi]) *
        position.multiplicator[$gi])
    """
end
function glsllinspace(grid::Grid{1}, gi, index)
    """
    (((float(position.dims)-($(index)+1)) *
        position.minimum + $(index)*position.maximum) *
        position.multiplicator)
    """
end
function grid_pos(grid::Grid{1})
    "$(glsllinspace(grid, 0, "index"))"
end
function grid_pos(grid::Grid{2})
    "vec2($(glsllinspace(grid, 0, "index2D.x")), $(glsllinspace(grid, 1, "index2D.y")))"
end
function grid_pos(grid::Grid{3})
    "vec3(
        $(glsllinspace(grid, 0, "index2D.x")),
        $(glsllinspace(grid, 1, "index2D.y")),
        $(glsllinspace(grid, 2, "index2D.z"))
    )"
end


function _position_calc{T<:AbstractFloat}(
        grid::Grid{2}, position_z::MatTypes{T}, target::Type{Texture}
    )
    """
    ivec2 index2D = ind2sub(position.dims, index);
    vec2 normalized_index = vec2(index2D) / vec2(position.dims);
    float height = texture(position_z, normalized_index+(offset/vec2(position.dims))).x;
    pos = vec3($(grid_pos(grid)), height);
    """
end

function _position_calc{T<:AbstractFloat}(
        position_x::MatTypes{T}, position_y::MatTypes{T}, position_z::MatTypes{T}, target::Type{Texture}
    )
"""
    ivec2 index2D = ind2sub(dims, index);
    vec2 normalized_index = vec2(index2D) / vec2(dims);
    vec2 offsetted_index = normalized_index + (offset/vec2(dims));
    pos = vec3(
        texture(position_x, offsetted_index).x,
        texture(position_y, offsetted_index).x,
        texture(position_z, offsetted_index).x
    );
"""
end

function _position_calc{T<:AbstractFloat}(
        position_x::VecTypes{T}, position_y::T, position_z::T, target::Type{TextureBuffer}
    )
    "pos = vec3(texelFetch(position_x, index).x, position_y, position_z);"
end
function _position_calc{T<:AbstractFloat}(
        position_x::VecTypes{T}, position_y::T, position_z::T, target::Type{GLBuffer}
    )
    "pos = vec3(position_x, position_y, position_z);"
end
function _position_calc{T<:FixedVector}(
        position_xyz::VecTypes{T}, target::Type{TextureBuffer}
    )
    "pos = texelFetch(position, index).xyz;"
end
function _position_calc{T<:FixedVector}(
        position_xyz::VecTypes{T}, target::Type{GLBuffer}
    )
    len = length(T)
    filler = join(ntuple(x->0, 3-len), ", ")
    needs_comma = len != 3 ? ", " : ""
    "pos = vec3(position $needs_comma $filler);"
end
function _position_calc{T<:AbstractFloat}(
        position_x::VecTypes{T}, position_y::VecTypes{T}, position_z::VecTypes{T},
        target::Type{TextureBuffer}
    )
    "pos = vec3(
        texelFetch(position_x, index).x,
        texelFetch(position_y, index).x,
        texelFetch(position_z, index).x
    );"
end
function _position_calc{T<:AbstractFloat}(
        position_x::VecTypes{T}, position_y::VecTypes{T}, position_z::VecTypes{T},
        target::Type{GLBuffer}
    )
    "pos = vec3(
        position_x,
        position_y,
        position_z
    );"
end
function _position_calc(
        position::Grid{1}, target
    )
    "
    pos = vec3($(grid_pos(position)), 0, 0);
    "
end
function _position_calc(
        position::Grid{2}, target
    )
    "
    ivec2 index2D = ind2sub(position.dims, index);
    pos = vec3($(grid_pos(position)), 0);
    "
end
function _position_calc{T}(
        position::Grid{2}, ::VecTypes{T}, target::Type{GLBuffer}
    )
    "
    ivec2 index2D = ind2sub(position.dims, index);
    pos = vec3($(grid_pos(position)), position_z);
    "
end
function _position_calc(
        position::Grid{3}, target
    )
    "
    ivec3 index2D = ind2sub(position.dims, index);
    pos = $(grid_pos(position));
    "
end
