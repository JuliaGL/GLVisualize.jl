immutable Sprite{T} <: FixedVector{T, 1}
	attribute_id::T # lookup attribute_id for attribute texture
end
immutable SpriteStyle{T} <: FixedVector{T, 2}
	color_id::T # lookup attribute_id for attribute texture
	technique::T
end

typealias GLSprite Sprite{Uint32}
typealias GLSpriteStyle SpriteStyle{Uint16}

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
const fn = Pkg.dir("GLVisualize", "src", "texture_atlas", "DejaVuSansMono.ttf")
@assert isfile(fn)

const DEFAULT_FONT_FACE = newface(fn)
const FONT_EXTENDS = Dict{Int, FontExtent}()
const ID_TO_CHAR = Dict{Int, Char}()


begin 
const local TEXTURE_ATLAS = TextureAtlas[]
get_texture_atlas() = isempty(TEXTURE_ATLAS) ? push!(TEXTURE_ATLAS, TextureAtlas())[] : TEXTURE_ATLAS[] # initialize only on demand
end
Base.get!(texture_atlas::TextureAtlas, glyph::Char, font) = get!(texture_atlas.mapping, (glyph, font)) do 
	uv, rect, extent 	= render(glyph, font, texture_atlas)
	
	bearing 			= extent.horizontal_bearing
	attributes 			= GLSpriteAttribute[
		GLSpriteAttribute(uv.x, uv.y, uv.w, uv.h), # last remaining digits are optional, so we use them to cache this calculation
		GLSpriteAttribute(bearing.x, -(uv.h-bearing.y), extent.advance...), 
	]
	i = texture_atlas.index
	push!(texture_atlas.attributes, attributes)
	texture_atlas.index = i+2
	FONT_EXTENDS[i-1] 	= extent # extends get saved for the attribute id
	ID_TO_CHAR[i-1] 	= glyph
	return i-1 # zero indexed for OpenGL
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
	bitmap, extent = renderface(face, glyph)
	rect 	= Rectangle(0,0,size(bitmap)...)
    uv 		= push!(ta.rectangle_packer, rect).area #find out where to place the rectangle
    uv == nothing && error("texture atlas is too small.") #TODO resize surface
    ta.images[uv] = reinterpret(Ufixed8, bitmap)
    uv, rect, extent
end
