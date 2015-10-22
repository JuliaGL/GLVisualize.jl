using FileIO, Images, GLVisualize, Reactive, ColorTypes, GLAbstraction, GeometryTypes, GLWindow

w, r = glscreen()
slider_s, slider = vizzedit(1f0:0.1f0:20f0, w.inputs)

img = restrict(map(RGBA{Float32}, load(joinpath(homedir(), "julia.png"))))

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
	area = Input(Rectangle{Int}(0,0, ((vec2i(bb.maximum)-m)+30)...))
	view(visualize(area, style=Cint(OUTLINED)), method=:fixed_pixel)
	robj[:model] = translationmatrix(Vec3f0(15,15,0)-bb.minimum)
	view(robj, method=:fixed_pixel)
end
screen(slider, w)

r()