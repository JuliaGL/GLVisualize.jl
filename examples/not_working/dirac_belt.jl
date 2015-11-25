using GeometryTypes, Quaternions, GLVisualize, Reactive, GLAbstraction
function quaternion_belt_trick()

    rad1 = 1f0 # outer circle
    rad2 = 0.2f0 # inner circle

    center1 = Point(rad1,rad1) # left
    center2 = Point(rad1+2f0,rad1) # right

    u1234 = Quaternion(0.,0.,1.,0.) # gets rotated
    axis  = Quaternion(0.,0.,0.,1.) # axis of qrotationdd
    mi  = 80
    mj  = 10
    rxs = zeros(Float32, mi+1,mj+1)
    rys = zeros(Float32, mi+1,mj+1)
    rzs = zeros(Float32, mi+1,mj+1)

    max_frames = 96
    dphi = 2*pi/(max_frames-1) # include both ends
    w, r = glscreen()

    u1234_s = foldp(u1234, bounce(1:max_frames)) do v0, _
        qrotation(axis, v0, dphi)
    end
    xyz = const_lift(plot_belts, rxs, rys, rzs, u1234_s, center1, center2, rad1, rad2)
    x = const_lift(getindex, xyz, 1)
    view(visualize(
       x, const_lift(getindex, xyz, 2), const_lift(getindex, xyz, 3), :surface
    ))

    r()
end


#------------------------------------

function plot_circles(center1, center2, rad1, rad2)
    mi      = 100
    iis     = 1:(mi+1)
    thetas  = 2*pi*(iis-1)/mi
    als     = cos(thetas)
    bls     = sin(thetas)

    for ii=2:(mi+1)
        #plot(center1[1]+rad1*[als[ii-1],als[ii]],center1[2]+rad1*[bls[ii-1],bls[ii]]) # left one
        #plot(center1[1]+rad2*[als[ii-1],als[ii]],center1[2]+rad2*[bls[ii-1],bls[ii]])
        #plot(center2[1]+rad1*[als[ii-1],als[ii]],center2[2]+rad1*[bls[ii-1],bls[ii]]) # right one
        #plot(center2[1]+rad2*[als[ii-1],als[ii]],center2[2]+rad2*[bls[ii-1],bls[ii]])
    end
end
#------------------------------------

function plot_belts(rxs, rys, rzs, u1234, center1, center2, rad1, rad2)
    mi  = 80
    mj  = 10
    iis = 1:(mi+1)
    rs  = rad1-((rad1-rad2)*(iis-1)/mi)
    for ii=1:(mi+1)
        jjs   = 1:(mj+1)
        xs    = (rad2/mj)*((jjs-1)-(mj/2))
        ys    = sqrt(rs[ii]*rs[ii]-xs.*xs)
        theta = 2*pi*(ii-1)/mi

        for jj=1:(mj+1)
            efgh    = Quaternion(0., xs[jj], ys[jj], 0.)
            wxyz    = qrotation(efgh, u1234, theta)
            rxs[ii,jj] = center1[1]+wxyz.v1
            rys[ii,jj] = center1[2]+wxyz.v2
            rzs[ii,jj] = wxyz.v3
        end
        #plot1(rxs-0.1*rzs, +rys, rzs, center1[1], center1[2], rad2) # left one
        #plot1(center2[1]+rxs+0.1*rzs, center2[2]+rys, rzs, center2[1], center2[2], rad2) # right one
    end
    rxs, rys, rzs
end

#------------------------------------

function plot1(sxs, sys, szs, xc, yc, rad2)
    hidz = (szs<0)
    txs  = sxs-xc
    tys  = sys-yc
    hidr = (((txs.*txs)+(tys.*tys))<(rad2*rad2))
    hid  = hidr&hidz
    sxs[hid] = NaN
    sys[hid] = NaN
    #plot(sxs,sys) # left one
end
quaternion_belt_trick()

#------------------------------------