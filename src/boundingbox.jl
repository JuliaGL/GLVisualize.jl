particle_grid_bb{T}(min_xy::Vec{2,T}, max_xy::Vec{2,T}, minmax_z::Vec{2,T}) = AABB(Vec(min_xy..., minmax_z[1]), Vec(max_xy..., minmax_z[2]))
