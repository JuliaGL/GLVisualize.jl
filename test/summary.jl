using GLAbstraction, GLWindow, GLVisualize
using FileIO, GeometryTypes, Reactive, Images
using Colors, Plots, StaticArrays
using Plots; glvisualize(size=(800, 300))


function benchscatter(timings, names, images; n = 30)
    yposs, xposs = Vector{Float64}[], Vector{Float64}[]
    binss, scales = Vector{Float64}[], Vector{Float64}[]
    x = 1; dist = -0.5:0.0001:0.5
    min_res = 100

    for ts in timings
        bins = zeros(n); mini, maxi = minimum(ts), maximum(ts)
        w = max(maxi - mini, 1)
        min_res = min(mini, min_res)
        for t in ts
            t == 0 && continue # ignore the zeros we added
            i = round(Int, ((t-mini)/w)*(n-1) + 1)
            bins[i] += 1
        end
        bins .= (/).(bins, maximum(bins))
        xpos = similar(ts)
        scale = similar(ts)
        for (j,t) in enumerate(ts)
            if t != 0 # ignore the zeros we added
                i = round(Int, ((t-mini)/w)*(n-1) + 1)
                xpos[j] = x + rand(dist)*bins[i]*3
                scale[j] = bins[i]
            else
                xpos[j] = x
                scale[j] = 0.0
            end
        end
        push!(scales, scale)
        push!(xposs, xpos)

        gap = w/n
        push!(yposs, [t+rand(dist)*gap for t in ts])
        push!(binss, bins)
        x += 5
    end

    mscale = map(hcat(scales...)) do s
        s==0 && return s # preserve 0.0
        clamp(s*3.0, 1.5, 3.5) # else, don't make things too small
    end
    p = scatter(
        xposs, yposs, marker_z=hcat(scales...),
        shape=:circle, leg=false, ms=mscale,
        markerstrokewidth=0f0, markeralpha=0.15f0,
        markercolor=cgrad(:inferno, scale=:exp),
        title="Frame rendering times",
        ylabel="time in ms",
    )
    x = [mean(x) for x in xposs] .- 2.5
    scatter!(
        x, fill(min_res-1, length(x)),
        shape=images, hover=names, ms=5
    )
    p
end

function summarize(window, config)
    # These are allowed to fail, since they depend on not installed packages
    allowed_to_fail = ("mesh_edit.jl", "billiard.jl")
    # open(homedir()*"/results.jls", "w") do io
    #     serialize(io, config.attributes)
    # end
    allowed_failures = filter(config.attributes) do k, dict
        !dict[:success] && (basename(k) in allowed_to_fail)
    end
    failures = filter(config.attributes) do k, dict
        !dict[:success] && !(basename(k) in allowed_to_fail)
    end
    successfull = filter(config.attributes) do k, dict
        dict[:success]
    end

    resize!(window, 800, 700)

    empty!(window)

    area = Signal(SimpleRectangle(0, 0, 800, 300))
    area2 = Signal(SimpleRectangle(0, 300, 800, 400))

    plot_screen = Screen(window, name=:plots, area=area)
    glvis_screen = Screen(window, name=:glvis, area=area2)
    GLVisualize.add_screen(plot_screen) # make main screen for Plots


    # ystat = [length(failures), length(allowed_failures), length(successfull)]
    # failur_plt = bar(
    #     ["failures", "allowed failures", "passed"],
    #     ystat,
    #     markerstrokewidth=0f0, leg=false,
    #     title="Test Statistic",
    #     color=[RGBA(0.8, 0.1, 0.2, 0.6), RGBA(0.8, 0.6, 0.1, 0.6),  RGBA(0.1, 0.5, 0.4, 0.6)],
    #     ylabel="number of tests",
    #     hover=map(string, ystat)
    # )
    benchmark_names = String[]; times = Vector{Float64}[]
    success_thumbs = Matrix{RGB{N0f8}}[]
    for (k,v) in successfull
        if haskey(v, :timings) && haskey(v, :thumbnail)
            push!(benchmark_names, basename(k))
            ts = v[:timings] .* 1000.0
            ts = if length(ts) < 300
                append!(ts, fill(0.0, 300 - length(ts)))
            elseif length(ts) > 300
                resize!(ts, 300) # resampling would be more accurate, I suppose
            end
            # take 300 samples, not including the first (JIT, yo)
            push!(times, ts) # for m
            img = rotl90(v[:thumbnail])
            for x in 1:size(img, 2)
                img[:, x] = reverse(view(img, 1:size(img, 1), x))
            end
            push!(success_thumbs, img)
        end
    end
    benchplot = benchscatter(times, benchmark_names, success_thumbs)
    gui()
    rows = 11
    len = length(success_thumbs)-1
    w = 64
    positions = Point2f0[((i%rows)*w*1.05, div(i, rows)*w*1.05) for i=0:len]
    positions = positions .+ Scalar(Point2f0(w/2, 0))

    imgs = visualize(
        (success_thumbs, positions),
        scale=Vec2f0(w), stroke_width=2f0
    )
    _view(imgs, glvis_screen)

    Plots.hover(imgs, benchmark_names, glvis_screen)
    GLWindow.waiting_renderloop(window)

    if !isempty(failures)
        error("Tests not passed with $(length(failures)) failures")
    end
end

# config gets inserted by ExampleRunner
summarize(GLWindow.rootscreen(config.window), config)
