using Images, Colors, GeometryTypes
using Reactive, FileIO, GLVisualize
using GLAbstraction, GeometryTypes, GLWindow

if !isdefined(:runtests)
	window = glscreen()
end
const record_interactive = true

# loadasset loads data from the GLVisualize asset folder and is defined as
# FileIO.load(assetpath(name))
doge = loadasset("doge.png")
# Convert to RGBA{Float32}. Float for filtering and 32 because it fits the GPU better
img = map(RGBA{Float32}, doge)
# create a slider that goes from 1-20 in 0.1 steps
slider_s, slider = widget(Signal(1f0), range=1f0:0.1f0:20f0, window)

# performant conversion to RGBAU8, implemted with a functor
# in 0.5 anonymous functions offer the same speed, so this wouldn't be needed
immutable ClampRGBAU8 end
@compat (::ClampRGBAU8)(x) = RGBA{U8}(clamp(comp1(x), 0,1), clamp(comp2(x), 0,1), clamp(comp3(x), 0,1), clamp(alpha(x), 0,1))

"""
Applies a gaussian filter to `img` and converts it to RGBA{U8}
"""
function myfilter(img, sigma)
	img = Images.imfilter_gaussian(img, [sigma, sigma])
	map(ClampRGBAU8(), img).data
end


startvalue = myfilter(img, value(slider_s))
# Use Reactive.async_map, to filter the image without blocking the main process
task, imgsig = async_map(myfilter, startvalue, Signal(img), slider_s)
# visualize the image signal
image_renderable = visualize(
    imgsig,
    model=translationmatrix(Vec3f0(50,100,0)),
    is_fully_opaque=false
)
_view(image_renderable)

vec2i(a,b,x...) = Vec{2,Int}(round(Int, a), round(Int, b))
vec2i(vec::Vec) = vec2i(vec...)
"""
creates a rectangle around `robj`
"""
function screen(robj)
	bb = value(boundingbox(robj))
	m  = vec2i(minimum(bb))
	area = SimpleRectangle{Float32}(0,0, ((vec2i(maximum(bb))-m)+30)...)

	_view(visualize((area, [Point2f0(0)]),
        color=RGBA{Float32}(0,0,0,0), stroke_color=RGBA{Float32}(0,0,0,0.7),
        stroke_width=3f0),
        camera=:fixed_pixel
    )
	robj.children[][:model] = translationmatrix(Vec3f0(15,15,0)-minimum(bb))
	_view(robj, camera=:fixed_pixel)
end
screen(slider)

if !isdefined(:runtests)
	renderloop(window)
end
