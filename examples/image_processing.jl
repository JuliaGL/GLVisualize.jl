using Images, ColorTypes, GeometryTypes, Reactive, FileIO, GLVisualize, GLAbstraction, GeometryTypes, GLWindow
w = glscreen()

# if link is broken, you can just use any path to an arbitrary file on your disk
julia_logo = download("https://camo.githubusercontent.com/e1ae5c7f6fe275a50134d5889a68f0acdd09ada8/687474703a2f2f6a756c69616c616e672e6f72672f696d616765732f6c6f676f5f68697265732e706e67")
img = restrict(map(RGBA{Float32}, load(julia_logo)))
slider_s, slider = vizzedit(1f0:0.1f0:20f0, w)
immutable Clamp01
end
call(::Clamp01, x) = RGBA{U8}(clamp(comp1(x), 0,1), clamp(comp2(x), 0,1), clamp(comp3(x), 0,1), clamp(alpha(x), 0,1))
function myfilter(img, sigma)
	img = Images.imfilter_gaussian(img, [sigma, sigma])
	map(Clamp01(), img).data
end

tasks, imgsig = async_map(myfilter, myfilter(img, value(slider_s)), Signal(img), slider_s)
robj = visualize(imgsig)
view(robj)

vec2i(a,b,x...) = Vec{2,Int}(round(Int, a), round(Int, b))
vec2i(vec::Vec) = vec2i(vec...)

function screen(robj, w)
	bb = value(boundingbox(robj))
	m = vec2i(minimum(bb))
	area = SimpleRectangle{Float32}(0,0, ((vec2i(maximum(bb))-m)+30)...)

	view(visualize((area, [Point2f0(0)]),
        color=RGBA{Float32}(0,0,0,0), stroke_color=RGBA{Float32}(0,0,0,0.7),
        stroke_width=2f0),
        method=:fixed_pixel
    )
	robj.children[][:model] = translationmatrix(Vec3f0(15,15,0)-minimum(bb))
	view(robj, method=:fixed_pixel)
end
screen(slider, w)

renderloop(w)
