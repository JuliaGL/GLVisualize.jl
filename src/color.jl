


#GLPlot.toopengl{T <: AbstractRGB}(colorinput::Input{T}) = toopengl(lift(x->AlphaColorValue(x, one(T)), RGBA{T}, colorinput))
#tohsva(rgba)     = HSVA(convert(HSV, rgba.c), rgba.alpha)
#torgba(hsva)     = AlphaColorValue(convert(RGB, hsva.c), hsva.alpha)
#tohsva(h,s,v,a)  = AlphaColorValue(HSV(float32(h), float32(s), float32(v)), float32(a))

#Base.convert{T <: AbstractAlphaColorValue}(typ::Type{T}, x::AbstractAlphaColorValue) = AlphaColorValue(convert(RGB{eltype(typ)}, x.c), convert(eltype(typ), x.alpha))
    
