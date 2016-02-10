if !isdefined(:runtests)
	using GLVisualize
	window = glscreen()
end

bars   = visualize(rand(Float32, 50,50))
view(bars, window)

if !isdefined(:runtests)
	renderloop(window)
end
