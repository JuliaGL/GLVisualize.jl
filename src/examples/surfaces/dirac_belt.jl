using GeometryTypes, Quaternions, GLVisualize, Reactive, GLAbstraction

function Quaternions.qrotation{T<:Real}(axis::Quaternion{T}, theta::T)
    ax = Vec{3,T}(axis.v1, axis.v2, axis.v3)
    qrotation(ax, theta)
end

function Quaternions.qrotation{T<:Real}(axis::Quaternion{T}, z::Quaternion{T}, theta::T)
    q = qrotation(axis, theta)
    q*z*conj(q)
end

function quaternion_belt_trick(timesignal)

    rad1 = 1f0 # outer circle
    rad2 = 0.2f0 # inner circle

    center1 = Point2f0(rad1,rad1) # left
    center2 = Point2f0(rad1+2f0,rad1) # right

    u1234 = Quaternion(0f0,0f0,1f0,0f0) # gets rotated
    axis  = Quaternion(0f0,0f0,0f0,1f0) # axis of qrotationdd
    mi  = 80
    mj  = 10
    rxs = zeros(Float32, mi+1,mj+1)
    rys = zeros(Float32, mi+1,mj+1)
    rzs = zeros(Float32, mi+1,mj+1)

    max_frames = 96
    dphi = 2*pi/(max_frames-1) # include both ends

    u1234_s = foldp(u1234, timesignal) do v0, _
        qrotation(axis, v0, Float32(dphi))
    end
    xyz = const_lift(plot_belts, rxs, rys, rzs, u1234_s, center1, center2, rad1, rad2)
    x = const_lift(getindex, xyz, 1)
    y = const_lift(getindex, xyz, 2)
    z = const_lift(getindex, xyz, 3)
    (x,y,z)
end

function plot_belts(rxs, rys, rzs, u1234, center1, center2, rad1, rad2)
    mi  = 80
    mj  = 10
    iis = 1f0:(mi+1f0)
    rs  = rad1-((rad1-rad2)*(iis-1f0)/mi)
    for ii=1:(mi+1)
        jjs   = 1f0:(mj+1f0)
        xs    = (rad2/mj)*((jjs-1f0)-(mj/2f0))
        ys    = sqrt(rs[ii]*rs[ii]-xs.*xs)
        theta = Float32(2*pi*(ii-1)/mi)

        for jj=1:(mj+1)
            efgh    = Quaternion(0f0, xs[jj], ys[jj], 0f0)
            wxyz    = qrotation(efgh, u1234, theta)
            rxs[ii,jj] = center1[1]+wxyz.v1
            rys[ii,jj] = center1[2]+wxyz.v2
            rzs[ii,jj] = wxyz.v3
        end
    end
    rxs, rys, rzs
end

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end

xyz = quaternion_belt_trick(timesignal)
_view(visualize(xyz, :surface), window)

if !isdefined(:runtests)
    renderloop(window)
end
