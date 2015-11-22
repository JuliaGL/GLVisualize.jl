typealias VolumeElTypes Union{Colorant, AbstractFloat}

@enum RaymarchAlgorithm IsoValue Absorption MaximumIntensityProjection

const default_style = Style{:default}()

function _default{T<:VolumeElTypes}(a::VolumeTypes{T}, s::Style{:iso}, data::Dict)
    data = _default(a, default_style, kw_args)
    data[:isovalue]  = 0.5f0
    data[:algorithm] = Absorption
    data
end

function _default{T<:VolumeElTypes}(a::VolumeTypes{T}, s::Style{:absorption}, data::Dict)
    data = _default(a, default_style, kw_args)
    data[:absorption] = 1f0
    data[:algorithm]  = Absorption
    data
end

function _default{T<:VolumeElTypes, X}(img::Images.Image{T, 3, X}, s::Style, data::Dict)
    if haskey(img.properties, "pixelspacing")
        spacing = Vec3f0(map(float, img.properties["pixelspacing"]))
        pdims   = Vec3f0(size(img))
        dims    = pdims .* spacing
        dims    = dims/maximum(dims)
        data[:dimensions] = dims
    end
    _default(img.data, s, data)
end


_default{T<:VolumeElTypes}(main::VolumeTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensities      = main => Texture
    dimensions       = Vec3f0(1)
    hull::GLUVWMesh  = Cube{Float32}(Vec3f0(0), dimensions)
    light_position   = Vec3f0(0.25, 1.0, 3.0)
    light_intensity  = Vec3f0(15.0)

    color            = default(Vector{RGBA}, s)
    color_norm       = Vec2f0(minimum(vol), maximum(vol))
    algorithm        = MaximumIntensityProjection
    shader           = GLVisualizeShader("util.vert", "volume.vert", "volume.frag")
    prerender        = +(
        (glEnable,   GL_CULL_FACE),
        (glCullFace, GL_FRONT),
    )
end
