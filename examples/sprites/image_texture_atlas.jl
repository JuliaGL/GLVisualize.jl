using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end
description = """
Example showing how to color particles from one single big image.
"""
# this is just one big texture
texture_atlas = loadasset("doge.png")
w, h = size(texture_atlas)
const n = 40
xrange = linspace(0, w, n)
yrange = linspace(0, h, n)
scale  = Vec2f0(step(xrange), step(yrange))

# position in a grid
positions = foldp([Point2f0((i/(n*n))*700) for i in 1:(n*n)], timesignal) do v0, t
    for i=1:(n*n)
        xi,yi = ind2sub((n,n), i)
        x,y = xrange[xi], yrange[yi]
        @inbounds v0[i] = Point2f0(x+(sin(t*2*pi)*400), y+(sin(0+y*t*0.01)*200)+(cos(t*2*pi)*200))
    end
    v0
end

# uv coordinates are normalized coordinates into the texture_atlas
# they need the start point and the width of each rectangle (sprites are rectangles)
# so you will not actually index with the circle primitive, but rather with
# with the quad of the particle (the rest of the quad is transparent)
# note, that for uv coordinates, the origin is on the top left corner
uv_offset_width = vec(Vec4f0[(x,y,x+(1/n),y+(1/n)) for x=linspace(0, 1, n), y=linspace(1, 0, n)])

# when position and scale are defined, We can leave the middle and radius of
# Circle undefined, so just passing the type.
distfield = visualize((Circle, positions),
    scale = scale,
    stroke_width = 1f0,
    uv_offset_width = uv_offset_width,
    stroke_color = RGBA{Float32}(0.9,0.9,0.9,1.0),
    image = texture_atlas,
    boundingbox = AABB(value(positions))
)
_view(distfield, window)


if !isdefined(:runtests)
    renderloop(window)
end
