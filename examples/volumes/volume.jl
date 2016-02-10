if !isdefined(:runtests)
	using GLVisualize, GLWindow
	window = glscreen()
	timesignal = bounce(linspace(0f0,1f0,360))
end

function volume_data(N)
	volume 	= Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
	max 	= maximum(volume)
	min 	= minimum(volume)
	volume 	= (volume .- min) ./ (max .- min)
end

volume = visualize(volume_data(128), :iso, isovalue=timesignal)
view(volume, window)


if !isdefined(:runtests)
	renderloop(window)
end
