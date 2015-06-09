function play{T}(array::Array{T, 3}, slice)
	array[:, :, slice]
end
function image_test_data(N)
	img 	= read(file"test.gif")
	giff 	= lift(play, img.data, bounce(1:size(img, 3)))
	return (giff, 
		RGBA{Float32}[rgba(sin(i), sin(j), cos(i), sin(j)*cos(i)) for i=1:0.1:N, j=1:0.1:N], 
		file"drawing.jpg",
		file"dealwithit.jpg")
end

push!(TEST_DATA2D, image_test_data(20)...)