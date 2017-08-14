using GLVisualize, GeometryTypes, Reactive, GLAbstraction, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end

description = """
The distancefield rendering technology is used to render Fonts and
vector graphics in GLVisualize.
This example shows how to generate and display distancefields yourself.
"""

const n1 = 30
positions = rand(Point2f0, n1).*1000f0


xy_data(x,y,i) = Float32(sin(y/2f0/i)+cos(i*x))
const n2 = 128
# a distance field is a Matrix{Float32} array, which encodes the distance to
# the border of a filled shape. Positive numbers are inside the shape, 0 is the
# border and negative number are outside.
# this is basically how we render text, since you can do anti aliasing very
# nicely when you know the distance to the border.
# For text we use one big texture and specify uv coordinates into this big texture
# for every particle. How this is done can be seen in example
# partices/sprites/image_texture_atlas.jl

dfield = map(timesignal) do t
    tpi = (2pi*t)+0.2
    Float32[xy_data(x,y,tpi) + 0.5f0 for x=1:n2, y=1:n2]
end
Base.rand(m::MersenneTwister, ::Type{N0f8}) = N0f8(rand(m, UInt8))
Base.rand(m::MersenneTwister, ::Type{T}) where {T <: Colorant} = T(ntuple(x->rand(m, eltype(T)), Val{length(T)})...)

distfield = visualize((DISTANCEFIELD, positions),
    stroke_width=4f0,
    scale=Vec2f0(120),
    stroke_color=rand(RGBA{Float32}, n1),
    color=rand(RGBA{Float32}, n1),
    distancefield=dfield
)
_view(distfield, window)


if !isdefined(:runtests)
    renderloop(window)
end
