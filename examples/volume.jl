using GLVisualize
w,r = glscreen()
function volume_data(N)
	volume 	= Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
	max 	= maximum(volume)
	min 	= minimum(volume)
	volume 	= (volume .- min) ./ (max .- min)
end

robj = visualize(volume_data(128))
view(visualize([
	visualize(robj[:intensities], :iso),
	robj
]))

r()