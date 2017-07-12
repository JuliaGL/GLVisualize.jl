using Images, Colors, GeometryTypes
using Reactive, FileIO, GLVisualize
using GLAbstraction, GeometryTypes, GLWindow, ImageFiltering

if !isdefined(:runtests)
    window = glscreen()
end
description = """
Simple slider example.
You can drag the number to change it interactively.
"""

# loadasset loads data from the GLVisualize asset folder and is defined as
# FileIO.load(assetpath(name))
racoon = loadasset("racoon.png")
# Convert to RGBA{Float32}. Float for filtering and 32 because it fits the GPU better
img = convert(Matrix{RGBA{Float32}}, racoon)

# create a slider that goes from 1-20 in 0.1 steps
slider, slider_s = widget(Signal(1f0), range = 1f0:0.1f0:20f0, window)

if !isdefined(:clamp01)
    function clamp01(color)
        mapc(color) do c
            clamp(c, 0, 1)
        end
    end
end
"""
Applies a gaussian filter to `img` and converts it to RGBA{N0f8}
"""
function myfilter(img, sigma)
    img = imfilter(img, KernelFactors.IIRGaussian((sigma, sigma)))
    # map color compononts and clamp them
    clamp01.(img)
end


startvalue = myfilter(img, value(slider_s))
# Use Reactive.async_map, to filter the image without blocking the main process
task, imgsig = async_map(myfilter, startvalue, Signal(img), slider_s)
# visualize the image signal
image_renderable = visualize(
    imgsig,
    model = translationmatrix(Vec3f0(50,100,0))
)

w = widths(value(boundingbox(slider)))
h = round(Int, w[2])

slider_screen = Screen(window, area = map(window.area) do a
    SimpleRectangle(0, 0, a.w, h)
end)
image_screen = Screen(window, area = map(window.area) do a
    SimpleRectangle(0, h, a.w, a.h-h)
end)
_view(image_renderable, image_screen, camera = :orthographic_pixel)
center!(image_screen, :orthographic_pixel)
_view(slider, slider_screen, camera = :fixed_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
