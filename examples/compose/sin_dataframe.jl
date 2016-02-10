using Colors, GLVisualize
using DataFrames, Gadfly, GLVisualize.ComposeBackend

if !isdefined(:runtests)
    window = glscreen()
end
const not_animated = true

gl_backend = ComposeBackend.GLVisualizeBackend(window)

xs = 0:0.1:20

df_cos = DataFrame(
    x=xs,
    y=cos(xs),
    ymin=cos(xs) .- 0.5,
    ymax=cos(xs) .+ 0.5,
    f="cos"
)
df_sin = DataFrame(
    x=xs,
    y=sin(xs),
    ymin=sin(xs) .- 0.5,
    ymax=sin(xs) .+ 0.5,
    f="sin"
)
df = vcat(df_cos, df_sin)
p = plot(df, x=:x, y=:y, ymin=:ymin, ymax=:ymax, color=:f, Geom.line, Geom.ribbon)


draw(gl_backend, p)

if !isdefined(:runtests)
renderloop(window)
end
