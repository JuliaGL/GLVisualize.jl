using FileIO, Images, GLVisualize, Reactive, ColorTypes, GLAbstraction, GeometryTypes, GLWindow

w, r = glscreen()
slider_s, slider = vizzedit(1f0:0.1f0:20f0, w.inputs)
# if link is broken, you can just use any path to an arbitrary file on your disk
julia_logo = download("https://camo.githubusercontent.com/e1ae5c7f6fe275a50134d5889a68f0acdd09ada8/687474703a2f2f6a756c69616c616e672e6f72672f696d616765732f6c6f676f5f68697265732e706e67")
img = restrict(map(RGBA{Float32}, load(julia_logo)))

function myfilter(img, sigma)
	img = imfilter_gaussian(img, [sigma, sigma])
	map(RGBA{U8}, img).data
end

imgsig = const_lift(myfilter, img, slider_s);
robj = visualize(imgsig)
view(robj)

vec2i(a,b,x...) = Vec{2,Int}(round(Int, a), round(Int, b))
vec2i(vec::Vec) = vec2i(vec...)
function screen(robj, w)
	bb = boundingbox(robj).value
	m = vec2i(bb.minimum)
	area = Signal(Rectangle{Int}(0,0, ((vec2i(bb.maximum)-m)+30)...))
	view(visualize(area, style=Cint(OUTLINED)), method=:fixed_pixel)
	robj[:model] = translationmatrix(Vec3f0(15,15,0)-bb.minimum)
	view(robj, method=:fixed_pixel)
end
screen(slider, w)

r()