using GLVisualize, GeometryTypes, Reactive, GLAbstraction
const S = -5f0
const W = 10f0
const N = 2000
const ps = (rand(Point3f0, N)*W)+S
const velocity = rand(Vec3f0, N)*0.01f0

w =glscreen()
const gravity = Vec3f0(0,0,-0.04)

BT = bounce(0f0:20f0)
upper_bound(x) = x>S+W
lower_bound(x) = x<S
function letitsnow(position, t)
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
particles = foldp(letitsnow, ps, BT)
rotation_angle  = bounce(0f0:1f0:360f0)
rotation 		= map(rotationmatrix_z, map(deg2rad, rotation_angle))
view(visualize(('\U2744', particles), scale=Vec2f0(0.2), billboard=true, model=rotation), method=:perspective)
renderloop(w)
