using Compose, Colors, GLAbstraction, Measures, GLVisualize, Reactive, GeometryTypes
using GLVisualize.ComposeBackend
#Compose.hcenter
#Compose.vtop

using Gadfly
#=
import DataFrames
xs = 0:0.1:20
rdaname = "SLID.rda"
data = DataFrames.DataFrame(DataFrames.read_rda(rdaname)["SLID"])
p = plot(data, x="Wages", color="Language", Geom.histogram)

#p = plot([sin, cos], 0, 25)
#p = plot(x=rand(1000)*3f0, y=rand(1000)*3f0)
p = plot(x=1:100, y=2.^rand(100),
     Scale.y_sqrt, Geom.point, Geom.smooth,
     Guide.xlabel("Stimulus"), Guide.ylabel("Response"), Guide.title("Cat Training"))

p = plot(x=rand(10), y=rand(10), Geom.point, Geom.line)


using Distributions
sds = [1, 1/2, 1/4, 1/8, 1/16, 1/32]
n = 10
ys = [mean(rand(Distributions.Normal(0, sd), n)) for sd in sds]
ymins = ys .- (1.96 * sds / sqrt(n))
ymaxs = ys .+ (1.96 * sds / sqrt(n))
p = plot(x=1:length(sds), y=ys, ymin=ymins, ymax=ymaxs,
     Geom.point, Geom.errorbar)
=#

#=

p = compose(context(0.0mm, 0.0mm, 200mm, 200mm),
        (context(), circle(), fill("bisque")),
        (context(), rectangle(), fill("tomato")))
p = compose(context(),
        rectangle([0.25, 0.5, 0.75], [0.25, 0.5, 0.75], [0.1], [0.1]),
        fill([LCHab(92, 10, 77), LCHab(68, 74, 192), LCHab(78, 84, 29)]),
        stroke([LCHab(5, 0, 77),LCHab(5, 77, 77),LCHab(50, 0, 8)]))
=#
using DataFrames
w = glscreen()
img = ComposeBackend.GLVisualizeBackend(w)
# xs = 0:0.1:20
#
# df_cos = DataFrame(
#     x=xs,
#     y=cos(xs),
#     ymin=cos(xs) .- 0.5,
#     ymax=cos(xs) .+ 0.5,
#     f="cos"
# )
#
# df_sin = DataFrame(
#     x=xs,
#     y=sin(xs),
#     ymin=sin(xs) .- 0.5,
#     ymax=sin(xs) .+ 0.5,
#     f="sin"
# )
#
# df = vcat(df_cos, df_sin)
#
# p = plot(df, x=:x, y=:y, ymin=:ymin, ymax=:ymax, color=:f, Geom.line, Geom.ribbon)
#
# x1 = rand(40)
# y1 = 4.*x1 .+ 2 .+randn(40)
# x2 = rand(40)
# y2 = -6.*x2 .+ 3 .+ randn(40)
# x  = [x1;x2]
# y  = [y1;y2]
# col = [fill("Slope 4",40); fill("Slope -6",40)]
# p = plot(x=x,y=y,colour=col, Geom.point, Geom.smooth(method=:lm))

p = compose(context(),
        rectangle([0.25, 0.5, 0.75], [0.25, 0.5, 0.75], [0.1], [0.1]),
        fill([LCHab(92, 10, 77), LCHab(68, 74, 192), LCHab(78, 84, 29)]),
        stroke([LCHab(5, 0, 77),LCHab(5, 77, 77),LCHab(50, 0, 8)]))

draw(img, p)
renderloop(w)
