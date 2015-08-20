immutable Sprite{T} <: FixedVector{1, T}
	#attribute_id::T # lookup attribute_id for attribute texture
	_::NTuple{1, T}
end
immutable SpriteStyle{T} <: FixedVector{2, T}
	#color_id::T # lookup attribute_id for attribute texture
	#technique::T
	_::NTuple{2, T}
end


immutable SpriteAttribute{T} <: FixedVector{4, T}
	_::NTuple{4, T}
	#u::T
	#v::T
	#x_scale::T
	#y_scale::T
end


typealias GLSpriteAttribute SpriteAttribute{Float16}
typealias GLSprite Sprite{Uint32}
typealias GLSpriteStyle SpriteStyle{Uint16}

type TextureAtlas
	rectangle_packer::RectanglePacker
	mapping 		::Dict{Any, Int} # styled glyph to index in sprite_attributes
	index 			::Int
	images 			::Texture{Ufixed8, 2}
	attributes 		::GPUVector{GLSpriteAttribute}
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
		Texture(fill(Ufixed8(0.0), initial_size...)),
		GPUVector(texture_buffer(GLSpriteAttribute[]))
	)
end



begin #basically a singleton for the textureatlas
const local TEXTURE_ATLAS = TextureAtlas[]
get_texture_atlas() = isempty(TEXTURE_ATLAS) ? push!(TEXTURE_ATLAS, TextureAtlas())[] : TEXTURE_ATLAS[] # initialize only on demand
end

Base.get!(texture_atlas::TextureAtlas, glyph::Char, font) = get!(texture_atlas.mapping, (glyph, font)) do 
	uv, rect, extent 	= render(glyph, font, texture_atlas)
	
	bearing 			= extent.horizontal_bearing
	attributes 			= GLSpriteAttribute[
		GLSpriteAttribute(uv.x, uv.y, uv.w, uv.h), # last remaining digits are optional, so we use them to cache this calculation
		GLSpriteAttribute(bearing[1], -(uv.h-bearing[2]), extent.advance...), 
	]
	i = texture_atlas.index
	push!(texture_atlas.attributes, attributes)
	texture_atlas.index = i+1
	i0 					= i-1# zero indexed for OpenGL and ascii compatibility
	FONT_EXTENDS[i0] 	= extent # extends get saved for the attribute id
	ID_TO_CHAR[i0] 		= glyph
	return i0 
end


Base.get!(texture_atlas::TextureAtlas, glyphs, font) = 
	map(glyph->get!(texture_atlas, glyph, font), collect(glyphs))

map_fonts(
		text, 
		font 			= DEFAULT_FONT_FACE, 
        texture_atlas 	= get_texture_atlas()
        ) = get!(texture_atlas, text, font)
get_font!(char::Char, 
			font 			= DEFAULT_FONT_FACE, 
	        texture_atlas 	= get_texture_atlas()
        ) = get!(texture_atlas, char, font)


function GLAbstraction.render(glyph::Char, font, ta::TextureAtlas, face=DEFAULT_FONT_FACE)
	#select_font_face(cc, font)
	bitmap, extent = renderface(face, glyph, (42, 42))
	rect = Rectangle(0, 0, size(bitmap)...)
    uv   = push!(ta.rectangle_packer, rect).area #find out where to place the rectangle
    uv == nothing && error("texture atlas is too small.") #TODO resize surface
    ta.images[uv] = reinterpret(Ufixed8, bitmap)
    uv, rect, extent
end

