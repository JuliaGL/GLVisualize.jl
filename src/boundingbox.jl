particle_grid_bb(min_xy::Vector2, max_xy::Vector2, minmax_z::Vector2) = AABB(Vec3(min_xy..., minmax_z[1]), Vec3(max_xy..., minmax_z[2]))
