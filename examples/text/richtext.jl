using GLVisualize, GeometryTypes, Colors, GLAbstraction
using GLAbstraction
using FixedSizeDictionaries

window = glscreen()

# GLAbstraction.const_lift is defined as
# const_lift(F, args...) = Reactive.map(F, map(Signal, args)...)
# and allows to also use constant arguments without manually wrapping
# them into signals

# Reactive.map takes a signal and transforms it by applying F into a new signal
# it's similar to Base.map, just over the time dimension (like registering a
# callback in a more traditional event system)
s = """wooot"""
dict = Dict()
color = map(collect(s)) do char
    c = get!(dict, char, RGBA{Float32}(rand(), rand(), rand(), 1))
    c::RGBA{Float32}
end

# view and visualize it!
view(visualize(s,
    model=translationmatrix(Vec3f0(0,600,0)), # move this up, since the text starts at 0 and goes down from there
    color=color,
    rotation=fill(Vec3f0(0,0,1), length(s))
), window)

@async renderloop(window)

rt = RichText(
    TextDefault,
    text,
    [],
    [],
    1:0
)
rt.defaults = TextDefault
resize!(rt, length(string(rand())))

gap = 200
for i=1:10
    x = string(rand())
    insert!(rt, x, rt.cursor, Dict(
        :start_position=>Point2f0(0, (i-1)*gap),
    ))
    rt.cursor += length(x)
end
gap = 300

for i=1:10
    x = string(rand())
    insert!(rt, x, rt.cursor, Dict(
        :color => RGBA{Float32}(1,0,0,1),
        :start_position=>Point2f0((i-1)*gap, 0),
        :rotation => Vec3f0(0,0,1)
    ))
    rt.cursor += length(x)
end
gap
