"""
A matrix of colors is interpreted as an image
"""
function _default{T <: Colorant}(main::MatTypes{T}, ::Style, data::Dict)
    @gen_defaults! data begin
        spatialorder = "yx"
    end
    if !(spatialorder in ("xy", "yx"))
        error("Spatial order only accepts \"xy\" or \"yz\" as a value. Found: $spatialorder")
    end
    ranges = get(data, :ranges) do
        const_lift(main, spatialorder) do m, s
            (0:size(m, s == "xy" ? 1 : 2), 0:size(m, s == "xy" ? 2 : 1))
        end
    end
    delete!(data, :ranges)
    @gen_defaults! data begin
        image = main => (Texture, "image, can be a Texture or Array of colors")
        primitive::GLUVMesh2D = const_lift(ranges) do r
            x, y = minimum(r[1]), minimum(r[2])
            xmax, ymax = maximum(r[1]), maximum(r[2])
            SimpleRectangle{Float32}(x, y, xmax - x, ymax - y)
        end => "the 2D mesh the image is mapped to. Can be a 2D Geometry or mesh"
        boundingbox           = const_lift(GLBoundingBox, primitive)
        preferred_camera      = :orthographic_pixel
        fxaa                  = false
        shader                = GLVisualizeShader(
            "fragment_output.frag", "uv_vert.vert", "texture.frag",
            view = Dict("uv_swizzle" => "o_uv.$(spatialorder)")
        )
    end
end
function _default{T <: Colorant}(main::VecTypes{T}, ::Style, data::Dict)
    @gen_defaults! data begin
        image                 = main => (Texture, "image, can be a Texture or Array of colors")
        primitive::GLUVMesh2D = SimpleRectangle{Float32}(0f0, 0f0, length(value(main)), 50f0) => "the 2D mesh the image is mapped to. Can be a 2D Geometry or mesh"
        boundingbox           = const_lift(GLBoundingBox, primitive)
        preferred_camera      = :orthographic_pixel
        fxaa                  = false
        shader                = GLVisualizeShader(
            "fragment_output.frag", "uv_vert.vert", "texture.frag",
            view = Dict("uv_swizzle" => "o_uv.xy")
        )
    end
end

"""
A matrix of Intensities will result in a contourf kind of plot
"""
function _default{T <: Intensity}(main::MatTypes{T}, s::Style, data::Dict)
    main_v = value(main)
    @gen_defaults! data begin
        ranges = (0:size(main_v, 1), 0:size(main_v, 2))
    end
    x, y, xw, yh = first(ranges[1]), first(ranges[2]), last(ranges[1]), last(ranges[2])
    @gen_defaults! data begin
        intensity             = main => Texture
        color_map             = default(Vector{RGBA{N0f8}},s) => Texture
        primitive::GLUVMesh2D = SimpleRectangle{Float32}(x, y, xw-x, yh-y)
        color_norm            = const_lift(extrema2f0, main)
        stroke_width::Float32 = 0.05f0
        levels::Float32       = 5f0
        stroke_color          = RGBA{Float32}(1,1,1,1)
        boundingbox           = GLBoundingBox(primitive)
        shader                = GLVisualizeShader("fragment_output.frag", "uv_vert.vert", "intensity.frag")
        preferred_camera      = :orthographic_pixel
        fxaa                  = false
    end
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
        fxaa          = false
    end
    rect = SimpleRectangle{Float32}(0f0,0f0, size(value(main))...)
    _default((rect, Point2f0[0]), s, data)
end


export play
"""
    play(img, timedim, t)

Slice a 3D array along axis `timedim` at time `t`.
This can be used to treat a 3D array like a video and create an image stream from it.
"""
function play{T}(array::Array{T, 3}, timedim::Integer, t::Integer)
    index = ntuple(dim-> dim == timedim ? t : Colon(), Val{3})
    array[index...]
end

"""
    play(buffer, video_stream, t)

Plays a video stream from VideoIO.jl. You need to supply the image `buffer`,
which will be reused for better performance.
"""
function play{T}(buffer::Array{T, 2}, video_stream, t)
    eof(video_stream) && seekstart(video_stream)
    w, h = size(buffer)
    buffer = reinterpret(UInt8, buffer, (3, w,h))
    read!(video_stream, buffer) # looses type and shape
    return reinterpret(T, buffer, (w,h))
end

# If the user is using the new Images, ImageAxes will be loaded
if isdefined(Images, :ImageAxes)
    unwrap(img::Images.ImageMeta) = unwrap(data(img))
    unwrap(img::AxisArray) = unwrap(img.data)
    unwrap(img::AbstractArray) = img

    GLAbstraction.gl_convert{T}(::Type{T}, img::AbstractArray) = _gl_convert(T, unwrap(img))
    _gl_convert{T}(::Type{T}, img::Array) = gl_convert(T, img)

    """
        play(img)

    Turns an Image into a video stream
    """
    function play{T}(img::HasAxesArray{T, 3})
        ax = timeaxis(img)
        if timeaxis(img) != nothing
            return const_lift(play, unwrap(img), timedim(img), loop(1:length(ax)))
        end
        error("Image has no time axis: axes(img) = $(axes(img))")
    end

    """
    Takes a 3D image and decides if it is a volume or an animated Image.
    """
    function _default{T}(img::HasAxesArray{T, 3}, s::Style, data::Dict)
        # We could do this as a @traitfn, except that those don't
        # currently mix well with non-trait specialization.
        if timeaxis(img) != nothing
            data[:spatialorder] = "yx"
            timedim = timedim(img)
            video_signal = const_lift(play, unwrap(img), timedim, loop(1:size(img, timedim)))
            return _default(video_signal, s, data)
        else
            ps = pixelspacing(img)
            spacing = Vec3f0(map(x-> x / maximum(ps), ps))
            pdims   = Vec3f0(map(length, indices(img)))
            dims    = pdims .* spacing
            dims    = dims/maximum(dims)
            data[:dimensions] = dims
            _default(unwrap(img), s, data)
        end
    end
    function _default{T <: AxisMatrix}(img::TOrSignal{T}, s::Style, data::Dict)
        @gen_defaults! data begin
            ranges = const_lift(img) do img
                ps = pixelspacing(img)
                spacing = Vec2f0(map(x-> x / maximum(ps), ps))
                pdims   = Vec2f0(map(length, indices(img)))
                dims    = pdims .* spacing
                dims    = dims / maximum(dims)
                (0:dims[1], 0:dims[2])
            end
        end
        _default(const_lift(unwrap, img), s, data)
    end

    """
    Displays 3D array as movie with 3rd dimension as time dimension
    """
    function _default{T}(img::AbstractArray{T, 3}, s::Style, data::Dict)
        video_signal = const_lift(play, unwrap(img), 3, loop(1:size(img, 3)))
        return _default(video_signal, s, data)
    end
else
    include_string("""
    GLAbstraction.gl_convert{T}(::Type{T}, img::Images.Image) = gl_convert(T, convert(Matrix, img))

    function _default{T <: Colorant, X}(main::TOrSignal{Images.Image{T, 2, X}}, s::Style, d::Dict)
        props = value(main).properties # TODO update this if signal
        if haskey(props, "spatialorder")
            so = props["spatialorder"]
            get!(d, :spatialorder, join(so, ""))
        end
        _default(const_lift(x-> convert(Matrix, x), main), s, d)
    end

    function play{T<:Colorant, X}(img::Images.Image{T, 3, X})
        props = img.properties
        if haskey(props, "timedim")
            timedim = props["timedim"]
            return const_lift(play, img.data, timedim, loop(1:size(img, timedim)))
        end
        error("Image has no time channel")
    end

    function _default{T<:Colorant, X}(img::Images.Image{T, 3, X}, s::Style, data::Dict)
        props = img.properties
        if haskey(props, "timedim")
            if haskey(props, "spatialorder")
                get!(data, :spatialorder, join(props["spatialorder"], ""))
            end
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

    function _default{T <: Colorant}(img::AbstractArray{T, 3}, s::Style, data::Dict)
        # TODO axis array and stuff
        video_signal = const_lift(play, img, 3, loop(1:size(img, 3)))
        return _default(video_signal, s, data)
    end
    """)
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
_default(func::String, s::Style{:shader}, data::Dict) = @gen_defaults! data begin
    color                 = default(RGBA, s) => Texture
    dimensions            = (120f0, 120f0)
    primitive::GLUVMesh2D = SimpleRectangle{Float32}(0f0,0f0, dimensions...)
    preferred_camera      = :orthographic_pixel
    boundingbox           = GLBoundingBox(primitive)
    fxaa                  = false
    shader                = GLVisualizeShader("fragment_output.frag", "parametric.vert", "parametric.frag", view=Dict(
         "function" => func
     ))
end


#Volumes
typealias VolumeElTypes Union{Gray, AbstractFloat, Intensity}

const default_style = Style{:default}()

function _default{T <: VolumeElTypes}(a::VolumeTypes{T}, s::Style{:iso}, data::Dict)
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
@compat function (::VolumePrerender)()
    GLAbstraction.StandardPrerender()()
    glEnable(GL_CULL_FACE)
    glCullFace(GL_FRONT)
end

_default{T <: VolumeElTypes}(main::VolumeTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensities      = main => Texture
    dimensions       = Vec3f0(1)
    hull::GLUVWMesh  = AABB{Float32}(Vec3f0(0), dimensions)
    light_position   = Vec3f0(0.25, 1.0, 3.0)
    light_intensity  = Vec3f0(15.0)

    color_map        = default(Vector{RGBA}, s) => Texture
    color_norm       = color_map == nothing ? nothing : const_lift(extrema2f0, main)
    color            = color_map == nothing ? default(RGBA, s) : nothing

    algorithm        = MaximumIntensityProjection
    boundingbox      = hull
    absorption       = 1f0
    isovalue         = 0.5f0
    isorange         = 0.01f0
    shader           = GLVisualizeShader("fragment_output.frag", "util.vert", "volume.vert", "volume.frag")
    prerender        = VolumePrerender()
    postrender       = () -> begin
        glDisable(GL_CULL_FACE)
    end
end
