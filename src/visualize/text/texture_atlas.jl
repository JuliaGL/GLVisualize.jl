immutable Glyph{T} <: FixedVector{T, 2}
	char::T
	style::T
end

typealias GLGlyph Glyph{Uint16}

immutable SpriteAttribute{T} <: FixedVector{T, 4}
	u::T
	v::T
	x_scale::T
	y_scale::T
end
typealias GLSpriteAttribute SpriteAttribute{Float16}



type TextureAtlas
	rectangle_store ::Node
	images 			::Texture{BGRA{Ufixed8}, 2}
	mapping 		::Dict{Tuple{Char, FontDescription}, Int} # styled glyph to index in sprite_attributes
	index 			::Int
	attributes 		::Texture{GLSpriteAttribute, 2}
	# sprite_attributes layout
	# ID Vertex1     Vertex2     Vertex3     Vertex4
	# 0  [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] # uv -> rectangular section in TextureAtlas
	# 1  ...
	# .
	# .
	# .
	TextureAtlas(initial_size=(2048, 2048)) = new(
		Node(Rectangle(0, 0, initial_size...)),
		Texture(fill(BGRA{Ufixed8}(1.0,0.0,0.0,0.0), initial_size...)),
		Dict{Any, Int}(),
		1,
		Texture(GLSpriteAttribute, (1024, 4))
	)
end
const TEXTURE_ATLAS = TextureAtlas()

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
		font 			= FontDescription("Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD, 100.0), 
        texture_atlas 	= TEXTURE_ATLAS
        ) = get!(texture_atlas, text, font)

const CAIRO_CONTEXT = CairoContext(CairoARGBSurface(zeros(Uint32, 1024, 1024)))

function GLAbstraction.render(glyph::Char, font::FontDescription, ta::TextureAtlas, cc=CAIRO_CONTEXT)
	select_font_face(cc, font)
	glyph 	= utf8(string(glyph))
	extent 	= FontExtent(cc, glyph)
	println(extent)
	rect 	= Rectangle(extent)
    uv 		= push!(ta.rectangle_store, rect).area #find out where to place the rectangle
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
