immutable FontExtent{T}
    bearing::Vector2{T}
    scale::Vector2{T}
    advance::Vector2{T}
end
immutable FontDescription
	name   ::UTF8String
	slant  ::Int32
	weight ::Int32
	size   ::Float64
end
typealias CairoFontExtent FontExtent{Float64}
FontExtent(cc::CairoContext, c::Char) 				= FontExtent(cc, string(c))
FontExtent(cc::CairoContext, t::AbstractString) 	= reinterpret(CairoFontExtent, text_extents(cc, t), (1,))[1]
GeometryTypes.Rectangle(cc::CairoContext, c::Char) 	= Rectangle(FontExtent(cc, c))
GeometryTypes.Rectangle(fe::FontExtent) 			= Rectangle(0,0,round(Int, fe.scale.x), round(Int, fe.scale.y))
function Cairo.select_font_face(cc::CairoContext, font::FontDescription) 
	select_font_face(cc, font.name, font.slant, font.weight)
	set_font_size(cc, font.size)
end

