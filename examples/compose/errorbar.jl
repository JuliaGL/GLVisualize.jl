using GLVisualize.ComposeBackend, Gadfly, Distributions
using Colors, GLVisualize

if !isdefined(:runtests)
    window = glscreen()
end

const not_animated = true
gl_backend = ComposeBackend.GLVisualizeBackend(window)

sds = [1, 1/2, 1/4, 1/8, 1/16, 1/32]
n = 10
ys = [mean(rand(Distributions.Normal(0, sd), n)) for sd in sds]
ymins = ys .- (1.96 * sds / sqrt(n))
ymaxs = ys .+ (1.96 * sds / sqrt(n))

p = plot(x=1:length(sds), y=ys, ymin=ymins, ymax=ymaxs,
     Geom.point, Geom.errorbar)

draw(gl_backend, p)

if !isdefined(:runtests)
	renderloop(window)
end
