GLAbstraction.gl_convert{T}(::Type{T}, img::Images.Image) = gl_convert(T, Images.data(img))

_default{T <: Colorant, X}(main::Images.Image{T, 2, X}, s::Style, d::Dict) = _default(Images.data(main), s, d)
_default{T <: Colorant, X}(main::Signal{Images.Image{T, 2, X}}, s::Style, d::Dict) = _default(const_lift(Images.data, main), s, d)


_default{T <: Colorant}(main::MatTypes{T}, ::Style, data::Dict) = @gen_defaults! data begin
    image                 = main => Texture
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0f0, 0f0, size(value(main))...)
    boundingbox           = GLBoundingBox(primitive)
    preferred_camera      = :orthographic_pixel
    shader                = GLVisualizeShader("uv_vert.vert", "texture.frag")
end

_default{T <: Intensity}(main::MatTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensity             = main => Texture
    color                 = default(Vector{RGBA{U8}},s) => Texture
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0,0,size(value(main))...)
    color_norm	          = const_lift(extrema2f0, main)
    boundingbox 	      = GLBoundingBox(primitive)
    shader                = GLVisualizeShader("uv_vert.vert", "intensity.frag")
    preferred_camera      = :orthographic_pixel
end

function _default{T <: AbstractFloat}(main::MatTypes{T}, s::style"distancefield", data::Dict)
    @gen_defaults! data begin
        distancefield = main => Texture
        shape         = DISTANCEFIELD
    end
    rect = SimpleRectangle{Float32}(0f0,0f0, size(value(main))...)
    _default((rect, Point2f0[0]), s, data)
end


export play
function play{T}(array::Array{T, 3}, timedim::Integer, t::Integer)
    index = ntuple(dim->dim==timedim ? t : Colon(), Val{3})
    array[index...]
end
function play{T<:Colorant, X}(img::Images.Image{T, 3, X})
    props = img.properties
    if haskey(props, "timedim")
        timedim = props["timedim"]
        return const_lift(play, img.data, timedim, loop(1:size(img, timedim)))
    end
    error("Image has no time channel")
end

function play{T}(buffer::Array{T, 2}, video_stream, t)
    eof(video_stream) && seekstart(video_stream)
    w,h 	= size(buffer)
    buffer 	= reinterpret(UInt8, buffer, (3, w,h))
    read!(video_stream, buffer) # looses type and shape
    return reinterpret(T, buffer, (w,h))
end

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

_default(func::Shader, s::Style, data::Dict) = @gen_defaults! data begin
    color                 = default(RGBA, s)  => Texture
    dimensions            = (120f0,120f0)
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0f0,0f0, dimensions...)
    preferred_camera      = :orthographic_pixel
    boundingbox           = GLBoundingBox(primitive)
    shader                = GLVisualizeShader("parametric.vert", "parametric.frag", view=Dict(
         "function" => bytestring(func.source)
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
    shader           = GLVisualizeShader("util.vert", "volume.vert", "volume.frag")
    prerender        = (
        (glEnable,   GL_CULL_FACE),
        (glCullFace, GL_FRONT),
    )
end
