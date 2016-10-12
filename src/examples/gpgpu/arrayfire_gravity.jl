#=
 * Copyright (c) 2014, ArrayFire
 * All rights reserved.
 *
 * This file is distributed under 3-clause BSD license.
 * The complete license agreement can be obtained at:
 * http:#arrayfire.com/licenses/BSD-3-Clause
=#
using ArrayFire, Cxx

width = 512; height = 512;
pixels_per_unit = 20;

function simulate(pos, vels, forces, dt)
    pos[1] += vels[1] * pixels_per_unit * dt
    pos[2] += vels[2] * pixels_per_unit * dt

    #calculate distance to center
    diff_x = pos[1] - width/2;
    diff_y = pos[2] - height/2;
    dist = sqrt( diff_x.*diff_x + diff_y.*diff_y )

    #calculate normalised force vectors
    forces[1] = -1 * diff_x ./ dist;
    forces[2] = -1 * diff_y ./ dist;
    #update force scaled to time and magnitude constant
    forces[1] *= pixels_per_unit * dt;
    forces[2] *= pixels_per_unit * dt;

    #dampening
    vels[1] *= 1 - (0.005*dt);
    vels[2] *= 1 - (0.005*dt);

    #update velocities from forces
    vels[1] = vels[1] .+ forces[1];
    vels[2] = vels[2] .+ forces[2];

end

function collisions(pos, vels)
    #clamp particles inside screen border
    projected_px = min(width, max(0, pos[1]))
    projected_py = min(height - 1, max(0, pos[2]))

    #calculate distance to center
    diff_x = projected_px - width/2
    diff_y = projected_py - height/2
    dist = sqrt( diff_x.*diff_x + diff_y.*diff_y )

    #collide with center sphere
    radius = 50;
    elastic_constant = 0.91f0
    dr = dist.<radius
    s = icxx"af::sum<int>($dr);"
    if s > 0
        vels[1][dr] = -elastic_constant * vels[1][dr]
        vels[2][dr] = -elastic_constant * vels[2][dr]

        #normalize diff vector
        diff_x = diff_x ./ dist
        diff_y = diff_y ./ dist
        #place all particle colliding with sphere on surface
        pos[1][dr] = width/2 + diff_x[dr] * radius
        pos[2][dr] = height/2 +  diff_y[dr] * radius
    end
end


function main()
    total_particles = 1000;
    reset = 500;
    frame_count = 0;

    # Initialize the kernel array just once
    # Generate a random starting state
    pos = Any[
        rand(AFArray{Float32}, total_particles) * width,
        rand(AFArray{Float32}, total_particles) * height
    ]

    vels = Any[
        randn(AFArray{Float32}, total_particles),
        randn(AFArray{Float32}, total_particles)
    ]

    forces = Any[
        randn(AFArray{Float32}, total_particles),
        randn(AFArray{Float32}, total_particles)
    ]


    tic();
    for i=1:10
        dt = toq();tic()

        frame_count += 1

        # Generate a random starting state
        if frame_count % reset == 0
            pos = [
                rand(AFArray{Float32}, total_particles) * width,
                rand(AFArray{Float32}, total_particles) * height
            ]
            vels = [
                randn(AFArray{Float32}, total_particles),
                randn(AFArray{Float32}, total_particles)
            ]
        end

        #check for collisions and adjust positions/velocities accordingly
        collisions(pos, vels);

        #run force simulation and update particles
        simulate(pos, vels, forces, dt);

    end
end
main()
