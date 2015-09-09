using FileIO, Images, GLVisualize, Reactive, ColorTypes

w, r = glscreen()
slider_s, slider = vizzedit(1f0:0.1f0:20f0, w.inputs)

@async r()
img = load("images.png")

function myfilter(img, sigma)
	img = imfilter_gaussian(img, [sigma, sigma])
	convert(Image{BGRA{U8}}, img).data
end

imgsig = const_lift(myfilter, img, slider_s);
view(visualize(imgsig))
view(slider)