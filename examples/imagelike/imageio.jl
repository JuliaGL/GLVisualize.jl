using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO
if !isdefined(:runtests)
    window = glscreen()
end

description = """
Demonstration of loding different image formats. The blank images and the ones
showing checkmarks should all be green. As you can see, you can also quite easily
load and display animated images.
"""

# a few helper functions to generate images

const NColor{N, T} = Colorant{T, N}
fillcolor(::Type{T}) where {T <: NColor{4}} = T(0,1,0,1)
fillcolor(::Type{T}) where {T <: NColor{3}} = T(0,1,0)

# create different images with different color types (not an exhaustive list of supported types)
arrays = map((RGBA{N0f8}, RGBA{Float32}, RGB{N0f8}, RGB{Float32}, BGRA{N0f8}, BGR{Float32})) do C
     C[fillcolor(C) for x=1:45,y=1:45]
 end
# load a few images from the asset folder with FileIO.load (that's what loadasset calls)
loaded_imgs = map(x->loadasset("test_images", x), readdir(assetpath("test_images")))

# combine them all into one array and add an animated gif and a few other images

# backward compatible imconvert
imconvert(im) = im
if isdefined(:Image)
    function imconvert(im::Image)
        if ndims(im) == 2
            convert(Array{eltype(im), ndims(im)}, im)
        else
            permutedims(im.data, (2, 1, 3))
        end
    end
end
x = Any[
    arrays..., loaded_imgs...,
    loadasset("kittens-look.gif"),
    loadasset("mario", "stand", "right.png"),
    loadasset("mario", "jump", "left.gif"),
]
x = map(imconvert, x)

# visualize all images and convert the array to be a vector of element type context
# This shouldn't be necessary, but it seems map is not able to infer the type alone
images = convert(Vector{Context}, map(visualize, x))
# make it a grid
images = reshape(images, (4, 4))
# GLVisualize offers a few helpers to visualize arrays of render objects
# spaced out as the underlying array. So this will create a grid whereas every
# item is 128x128x128 pixels big
img_vis = visualize(images, scale = Vec3f0(128))
_view(img_vis, window)



if !isdefined(:runtests)
    renderloop(window)
end
