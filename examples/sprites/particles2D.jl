using GLVisualize, GeometryTypes, Reactive, GLAbstraction

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0,1,360))
end


function spiral(i, start_radius, offset)
	Point2f0(sin(i), cos(i)) * (start_radius + ((i/2pi)*offset))
end
# 2D particles
particle_data2D(i, N) = Point2f0[spiral(i+x, 3, 10) for x=1:N]
# stretch time a bit:
t = const_lift(*, timesignal, 30f0)

# the simplest of all, plain 2D particles.
# to make it a little more interesting, we animate the particles a bit!
particles = const_lift(particle_data2D, t, 256)

# create a visualisation with each particle being 15px wide
# if you omit the primitive, it defaults to a SimpleRectangle
vis = visualize(particles, scale=Vec2f0(15))
view(vis, window, camera=:orthographic_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
