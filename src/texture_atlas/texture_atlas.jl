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
	images 			::Texture{Ufixed8, 2}
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
		Texture(fill(Ufixed8(0.0), initial_size...)),
		Texture(GLSpriteAttribute, (1024, 4))
	)
end
const fn = Pkg.dir("GLVisualize", "src", "texture_atlas", "DejaVuSansMono.ttf")
@assert isfile(fn)

const DEFAULT_FONT_FACE = newface(fn)
const FONT_EXTENDS = Dict{Char, FontExtent}()


begin 
const local TEXTURE_ATLAS = TextureAtlas[]
get_texture_atlas() = isempty(TEXTURE_ATLAS) ? push!(TEXTURE_ATLAS, TextureAtlas())[] : TEXTURE_ATLAS[] # initialize only on demand
end
Base.get!(texture_atlas::TextureAtlas, glyph::Char, font) = get!(texture_atlas.mapping, (glyph, font)) do 
	uv, rect, extent = render(glyph, font, texture_atlas)
	FONT_EXTENDS[glyph] = extent
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


Base.get!(texture_atlas::TextureAtlas, glyphs::AbstractString, font) = 
	map(glyph->get!(texture_atlas, glyph, font), collect(glyphs))

map_fonts(
		text::AbstractString, 
		font 			= DEFAULT_FONT_FACE, 
        texture_atlas 	= get_texture_atlas()
        ) = get!(texture_atlas, text, font)

function GLAbstraction.render(glyph::Char, font, ta::TextureAtlas, face=DEFAULT_FONT_FACE)
	#select_font_face(cc, font)
	bitmap, extent = renderface(face, glyph)
	rect 	= Rectangle(0,0,size(bitmap)...)
    uv 		= push!(ta.rectangle_packer, rect).area #find out where to place the rectangle
    uv == nothing && error("texture atlas is too small.") #TODO resize surface
    ta.images[uv] = reinterpret(Ufixed8, bitmap)
    uv, rect, extent
end
