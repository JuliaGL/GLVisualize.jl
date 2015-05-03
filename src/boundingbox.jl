import GeometryTypes.AABB
particle_grid_bb(min_xy::Vector2, max_xy::Vector2, minmax_z::Vector2) = AABB(Vec3(min_xy..., minmax_z[1]), Vec3(max_xy..., minmax_z[2]))
    
AABB(min_x, min_y, min_z, max_x, max_y, max_z) = AABB(Vector3(min_x, min_y, min_z), Vector3(max_x, max_y, max_z))
AABB(min_x, min_y, min_z, max_x, max_y, max_z) = AABB(Vector3(min_x, min_y, min_z), Vector3(max_x, max_y, max_z))

function convert{T}(::Type{AABB}, geometry::Array{Point3{T}}) 
    vmin = Point3(typemax(T))
    vmax = Point3(typemin(T))
    @inbounds for i=1:length(geometry)
         vmin = min(geometry[i], vmin)
         vmax = max(geometry[i], vmax)
    end
    AABB(Vector3{T}(vmin), Vector3{T}(vmax))
end
