immutable Sprite{T} <: FixedVector{T, 2}
	attribute_id::T # lookup attribute_id for attribute texture
	style_id::T # style_id to look up in a style array (e.g. an array of colors)
end
typealias GLSprite Sprite{Uint16}
immutable SpriteAttribute{T} <: FixedVector{T, 4}
	u::T
	v::T
	x_scale::T
	y_scale::T
end

typealias GLSpriteAttribute SpriteAttribute{Float16}

type TextureAtlas
	rectangle_packer::RectanglePacker
	mapping 		::Dict{Any, Int} # styled glyph to index in sprite_attributes
	index 			::Int
	images 			::Texture{BGRA{Ufixed8}, 2}
	attributes 		::Texture{GLSpriteAttribute, 2}
	# sprite_attributes layout
	# can be compressed quite a bit more
	# ID Vertex1     Vertex2     Vertex3     Vertex4
	# 0  [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] # uv -> rectangular section in TextureAtlas
	# 1  ...
	# .
	# .
	# .
	TextureAtlas(initial_size=(4096, 4096)) = new(
		RectanglePacker(Rectangle(0, 0, initial_size...)),
		Dict{Any, Int}(),
		1,
		Texture(fill(BGRA{Ufixed8}(1.0,0.0,0.0,0.0), initial_size...)),
		Texture(GLSpriteAttribute, (1024, 4))
	)
end
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
FontExtent(cc::CairoContext, c::Char)               = FontExtent(cc, string(c))
FontExtent(cc::CairoContext, t::AbstractString)     = reinterpret(CairoFontExtent, text_extents(cc, t), (1,))[1]
GeometryTypes.Rectangle(cc::CairoContext, c::Char)  = Rectangle(FontExtent(cc, c))
GeometryTypes.Rectangle(fe::FontExtent)             = Rectangle(0,0,round(Int, fe.scale.x), round(Int, fe.scale.y))
function Cairo.select_font_face(cc::CairoContext, font::FontDescription) 
    select_font_face(cc, font.name, font.slant, font.weight)
    set_font_size(cc, font.size)
end 
const DEFAULT_FONT_FACE = FontDescription("Meslo LG L DZ", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL,50.0)
const CAIRO_CONTEXT = CairoContext(CairoARGBSurface(zeros(Uint32, 1024, 1024)))
select_font_face(CAIRO_CONTEXT, DEFAULT_FONT_FACE) 



begin 
const local TEXTURE_ATLAS = TextureAtlas[]
get_texture_atlas() = isempty(TEXTURE_ATLAS) ? push!(TEXTURE_ATLAS, TextureAtlas())[] : TEXTURE_ATLAS[]
end
Base.get!(texture_atlas::TextureAtlas, glyph::Char, font::FontDescription) = get!(texture_atlas.mapping, (glyph, font)) do 
	uv, rect 	= render(glyph, font, texture_atlas)
	attributes 	= GLSpriteAttribute[
		GLSpriteAttribute(rect.w, rect.h, uv.x, uv.y+uv.h),
		GLSpriteAttribute(rect.w, rect.h, uv.x, uv.y),
		
		GLSpriteAttribute(rect.w, rect.h, uv.x+uv.w, uv.y),
		GLSpriteAttribute(rect.w, rect.h, uv.x+uv.w, uv.y+uv.h),
	]
	i = texture_atlas.index
	texture_atlas.attributes[i, :] 		 = attributes
	texture_atlas.index 				 = i+1
	return i-1 # zero indexed for OpenGL
end


Base.get!(texture_atlas::TextureAtlas, glyphs::AbstractString, font::FontDescription) = 
	map(glyph->get!(texture_atlas, glyph, font), collect(glyphs))

map_fonts(
		text::AbstractString, 
		font 			= DEFAULT_FONT_FACE, 
        texture_atlas 	= get_texture_atlas()
        ) = get!(texture_atlas, text, font)


function GLAbstraction.render(glyph::Char, font::FontDescription, ta::TextureAtlas, cc=CAIRO_CONTEXT)
	#select_font_face(cc, font)
	glyph 	= utf8(string(glyph))
	extent 	= FontExtent(cc, glyph)
	rect 	= Rectangle(extent)
    uv 		= push!(ta.rectangle_packer, rect).area #find out where to place the rectangle
    cw, ch  = cc.surface.width, cc.surface.height
    rect.w > cw || rect.h > ch && error("surface is too small.") #TODO resize surface
	save(cc)
	set_source_rgba(cc, 0,0,0,1)
	paint(cc)
	set_source_rgba(cc, 1,1,1, 1)
    move_to(cc, (-extent.bearing)...)
    show_text(cc, glyph)
    data = reinterpret(BGRA{Ufixed8}, cc.surface.data)
    ta.images[uv] = data[rect]
    uv,rect
end
