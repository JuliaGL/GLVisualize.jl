
RGBAU8 = AlphaColorValue{RGB{Ufixed8}, Ufixed8}
Color.rgba(r::Real, g::Real, b::Real, a::Real)    = AlphaColorValue(RGB{Float32}(r,g,b), float32(a))
rgbaU8(r::Real, g::Real, b::Real, a::Real)  = AlphaColorValue(RGB{Ufixed8}(r,g,b), ufixed8(a))

#GLPlot.toopengl{T <: AbstractRGB}(colorinput::Input{T}) = toopengl(lift(x->AlphaColorValue(x, one(T)), RGBA{T}, colorinput))
tohsva(rgba)     = AlphaColorValue(convert(HSV, rgba.c), rgba.alpha)
torgba(hsva)     = AlphaColorValue(convert(RGB, hsva.c), hsva.alpha)
tohsva(h,s,v,a)  = AlphaColorValue(HSV(float32(h), float32(s), float32(v)), float32(a))

Base.convert{T <: AbstractAlphaColorValue}(typ::Type{T}, x::AbstractAlphaColorValue) = AlphaColorValue(convert(RGB{eltype(typ)}, x.c), convert(eltype(typ), x.alpha))
    
