immutable Particle
    mass
    position
    force
    function Particle{T}(p::Vec{3, T}, m::T) 
        if m < 0.001
          m = 0.001
        end
     
        mass = m;
        inv_mass = 1.0 / mass;
    end
end
 
function setup(num, d, particles)
    dim = 50f0;
    len = d;
    pos = Vec3(300, 300, 0);
    mass = rand(1.0f, 10.0f)
    for i=1:num
        Particle(pos, mass)
        particles.push_back(p);
        pos.y += d;
    end
  end
 
function addForce(f::Vec3, particles)
    for i=1:length(particles)
        particles[i] = 
        p.forces += f;
    end
end
 
function update()
    dt = 1.0f0/20.0f0;
    # update velocities
    N = length(particles)
    for i=1:N
        p = particles[i]
        particles[i] = Particle(
            p.velocity + dt * (p.forces * p.inv_mass),
            p.tmp_position + (p.velocity * dt),
            0,
            p.velocity * 0.99
        )
    end  
 
    # solve constraints
    dir = Vec3f0(0)
    curr_pos = Vec3f0(0)
    for i=2:N
        pa = particles[i - 1]
        pb = particles[i]
        curr_pos = pb.tmp_position
        dir = pb.tmp_position - pa.tmp_position
        dir = normalize(dir)
        pb.tmp_position = pa.tmp_position + dir * len;
        pb.d = curr_pos - pb.tmp_position; #  - curr_pos;
    end 
 
    for i=2:N
        pa = particles[i-1]
        pb = particles[i]
        pa.velocity = ((pa.tmp_position - pa.position) / dt) + 0.9 *  (pb.d / dt);
        pa.position = pa.tmp_position;
    end
 
    lastp = last(particles)
    last.position = last.tmp_position;
end
 