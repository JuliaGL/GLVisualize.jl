function image_test_data(N)
	return (
		file"test.mp4", 
		RGBA{Float32}[rgba(sin(i), sin(j), cos(i), sin(j)*cos(i)) for i=1:0.1:N, j=1:0.1:N], 
		file"drawing.jpg",
		file"dealwithit.jpg",
		file"feelsgood.png",
		file"success.gif"
	)
end

push!(TEST_DATA2D, image_test_data(20)...)