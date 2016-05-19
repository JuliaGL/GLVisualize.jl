GLAbstraction.gl_convert{T}(::Type{T}, img::Images.Image) = gl_convert(T, Images.data(img))

_default{T <: Colorant, X}(main::Images.Image{T, 2, X}, s::Style, d::Dict) = _default(Images.data(main), s, d)
_default{T <: Colorant, X}(main::Signal{Images.Image{T, 2, X}}, s::Style, d::Dict) = _default(const_lift(Images.data, main), s, d)

"""
A matrix of colors is interpreted as an image
"""
_default{T <: Colorant}(main::MatTypes{T}, ::Style, data::Dict) = @gen_defaults! data begin
    image                 = main => (Texture, "image, can be a Texture or Array of colors")
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0f0, 0f0, size(value(main))...) => "the 2D mesh the image is mapped to. Can be a 2D Geometry or mesh"
    boundingbox           = GLBoundingBox(primitive)
    preferred_camera      = :orthographic_pixel
    shader                = GLVisualizeShader("fragment_output.frag", "uv_vert.vert", "texture.frag")
end

"""
A matrix of Intensities will result in a contourf kind of plot
"""
_default{T <: Intensity}(main::MatTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensity             = main => Texture
    color                 = default(Vector{RGBA{U8}},s) => Texture
    grid_size             = size(value(main))
    grid_start            = (0, 0)
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(grid_start..., grid_size...)
    color_norm	          = const_lift(extrema2f0, main)
    boundingbox 	      = GLBoundingBox(primitive)
    shader                = GLVisualizeShader("fragment_output.frag", "uv_vert.vert", "intensity.frag")
    preferred_camera      = :orthographic_pixel
end

"""
Float matrix with the style distancefield will be interpreted as a distancefield.
A distancefield is describing a shape, with positive values denoting the inside
of the shape, negative values the outside and 0 the border
"""
function _default{T <: AbstractFloat}(main::MatTypes{T}, s::style"distancefield", data::Dict)
    @gen_defaults! data begin
        distancefield = main => Texture
        shape         = DISTANCEFIELD
    end
    rect = SimpleRectangle{Float32}(0f0,0f0, size(value(main))...)
    _default((rect, Point2f0[0]), s, data)
end


export play
"""
With play, you can slice a 3D array along `timedim` at time `t`.
This can be used to treat a 3D array like a video and create an image stream from it.
"""
function play{T}(array::Array{T, 3}, timedim::Integer, t::Integer)
    index = ntuple(dim->dim==timedim ? t : Colon(), Val{3})
    array[index...]
end
"""
Turns an Image into a video stream
"""
function play{T<:Colorant, X}(img::Images.Image{T, 3, X})
    props = img.properties
    if haskey(props, "timedim")
        timedim = props["timedim"]
        return const_lift(play, img.data, timedim, loop(1:size(img, timedim)))
    end
    error("Image has no time channel")
end
"""
Plays a video stream from VideoIO.jl. You need to supply the image `buffer`,
which will be reused for better performance.
"""
function play{T}(buffer::Array{T, 2}, video_stream, t)
    eof(video_stream) && seekstart(video_stream)
    w,h 	= size(buffer)
    buffer 	= reinterpret(UInt8, buffer, (3, w,h))
    read!(video_stream, buffer) # looses type and shape
    return reinterpret(T, buffer, (w,h))
end

"""
Takes a 3D image and decides if it is a volume or an animated Image.
"""
function _default{T<:Colorant, X}(img::Images.Image{T, 3, X}, s::Style, data::Dict)
    props = img.properties
    if haskey(props, "timedim")
        timedim = props["timedim"]
        video_signal = const_lift(play, img.data, timedim, loop(1:size(img, timedim)))
        return _default(video_signal, s, data)
    elseif haskey(props, "pixelspacing")
        spacing = Vec3f0(map(float, img.properties["pixelspacing"]))
        pdims   = Vec3f0(size(img))
        dims    = pdims .* spacing
        dims    = dims/maximum(dims)
        data[:dimensions] = dims
    end
    _default(img.data, s, data)
end

"""
Takes a shader as a parametric function. The shader should contain a function stubb
like this:
```GLSL
uniform float arg1; // you can add arbitrary uniforms and supply them via the keyword args
float function(float x) {
 return arg1*sin(1/tan(x));
}
```
"""
_default(func::Shader, s::Style, data::Dict) = @gen_defaults! data begin
    color                 = default(RGBA, s)  => Texture
    dimensions            = (120f0,120f0)
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0f0,0f0, dimensions...)
    preferred_camera      = :orthographic_pixel
    boundingbox           = GLBoundingBox(primitive)
    shader                = GLVisualizeShader("fragment_output.frag", "parametric.vert", "parametric.frag", view=Dict(
         "function" => Compat.String(func.source)
     ))
end


#Volumes
typealias VolumeElTypes Union{Colorant, AbstractFloat}

const default_style = Style{:default}()

function _default{T<:VolumeElTypes}(a::VolumeTypes{T}, s::Style{:iso}, data::Dict)
    data = @gen_defaults! data begin
        isovalue  = 0.5f0
        algorithm = IsoValue
    end
     _default(a, default_style, data)
end

function _default{T<:VolumeElTypes}(a::VolumeTypes{T}, s::Style{:absorption}, data::Dict)
    data = @gen_defaults! data begin
        absorption = 1f0
        algorithm  = Absorption
    end
    _default(a, default_style, data)
end

immutable VolumePrerender
end
function call(::VolumePrerender)
    GLAbstraction.StandardPrerender()()
    glEnable(GL_CULL_FACE)
    glCullFace(GL_FRONT)
end

_default{T<:VolumeElTypes}(main::VolumeTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensities      = main => Texture
    dimensions       = Vec3f0(1)
    hull::GLUVWMesh  = AABB{Float32}(Vec3f0(0), dimensions)
    light_position   = Vec3f0(0.25, 1.0, 3.0)
    light_intensity  = Vec3f0(15.0)

    color            = default(Vector{RGBA}, s) => Texture
    color_norm       = const_lift(extrema2f0, main)
    algorithm        = MaximumIntensityProjection
    boundingbox      = hull
    shader           = GLVisualizeShader("fragment_output.frag", "util.vert", "volume.vert", "volume.frag")
    prerender        = VolumePrerender()
end
