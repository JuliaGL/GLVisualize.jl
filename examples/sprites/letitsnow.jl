using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0,1f0, 360))
end

description = """
Animating unicode particles.
"""

const S = -5f0
const W = 10f0
const N = 1000
const ps = (rand(Point3f0, N)*W)+S
const velocity = rand(Vec3f0, N)*0.01f0
const gravity  = Vec3f0(0,0,-0.04)

upper_bound(x) = x>S+W
lower_bound(x) = x<S
function let_it_snow(position, t)
    @inbounds for i=1:length(ps)
        pos = Vec(position[i])
        p = Point3f0(pos+gravity+velocity[i])
        if any(upper_bound, p) || any(lower_bound, p)
            position[i] = Point3f0(rand(linspace(S,S+W, 1000)),rand(linspace(S,S+W, 1000)), S+W)
            velocity[i] = Vec3f0(0)
        else
            position[i] = p
        end
    end
    position
end
particles       = foldp(let_it_snow, ps, timesignal)
rotation 		= map(rotationmatrix_z, const_lift(*, timesignal, 2f0*pi))
color_ramp      = colormap("Blues", 50)
colors          = RGBA{Float32}[color_ramp[rand(1:50)] for i=1:N]

snowflakes = visualize(
    ('❄', particles),
    color = colors,
    scale = Vec2f0(0.6),
    billboard = true, model = rotation
)

_view(snowflakes, window, camera=:perspective)


if !isdefined(:runtests)
    renderloop(window)
end
