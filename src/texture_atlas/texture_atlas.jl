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
typealias GLSprite Sprite{UInt32}
typealias GLSpriteStyle SpriteStyle{UInt16}
const GL_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE

type TextureAtlas
	rectangle_packer::RectanglePacker
	mapping 		::Dict{Any, Int} # styled glyph to index in sprite_attributes
	index 			::Int
	images 			::Texture{Float16, 2}
	attributes 		::GPUVector{GLSpriteAttribute}
	# sprite_attributes layout
	# can be compressed quite a bit more
	# ID Vertex1     Vertex2     Vertex3     Vertex4
	# 0  [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] # uv -> rectangular section in TextureAtlas
	# 1  ...
	# .
	# .
	# .
	function TextureAtlas(initial_size=(4096, 4096))

		images = Texture(fill(Float16(0.0), initial_size...), minfilter=:linear, magfilter=:linear)
		glBindTexture(GL_TEXTURE_2D, images.id)
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16)
		glBindTexture(GL_TEXTURE_2D, 0)

		new(
			RectanglePacker(Rectangle(0, 0, initial_size...)),
			Dict{Any, Int}(),
			1,
			images,
			GPUVector(texture_buffer(GLSpriteAttribute[]))
		)
	end
end



begin #basically a singleton for the textureatlas
const local TEXTURE_ATLAS = TextureAtlas[]
get_texture_atlas() = isempty(TEXTURE_ATLAS) ? push!(TEXTURE_ATLAS, TextureAtlas())[] : TEXTURE_ATLAS[] # initialize only on demand
end

Base.get!(texture_atlas::TextureAtlas, glyph::Char, font) = get!(texture_atlas.mapping, (glyph, font)) do 
	uv, rect, extent, real_width = render(glyph, font, texture_atlas)
	tex_size 			= Vec2f0(size(texture_atlas.images))
	uv_start 			= Vec2f0(uv.x, uv.y)
	uv_width 			= Vec2f0(uv.w, uv.h)
	halfpadding 		= (uv_width - real_width) / 2f0
	real_start 			= uv_start + halfpadding # include padding
	real_start 			/= tex_size # use normalized texture coordinates
	real_width 			/= tex_size
	
	bearing 			= extent.horizontal_bearing
	attributes 			= GLSpriteAttribute[
		GLSpriteAttribute(real_start..., real_width...), # last remaining digits are optional, so we use them to cache this calculation
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


function sdistancefield(img, min_size=64)
	w, h = size(img)
	w1, h1 = w, h
	restrict_steps = 0
	while w1 > 64 || h1 > 64
		restrict_steps += 1
		w1, h1 = Images.restrict_size(w1), Images.restrict_size(h1)
	end
	halfpad = 2*(2^restrict_steps) # padd so that after restrict it comes out as roughly 4 pixel
	w, h = w+2halfpad, h+2halfpad #pad this, to avoid cuttoffs
	in_or_out = Bool[begin
		x, y = i-halfpad, j-halfpad
		if checkbounds(Bool, size(img), x,y)
			img[x,y] >  0.5
		else
			false 
		end
	end for i=1:w, j=1:h]
	sd = sdf(in_or_out)
	for i=1:restrict_steps 
		sd = Images.restrict(sd) #downsample
	end
	sz = Vec2f0(size(img))
	maxlen = norm(sz)
	sw, sh = size(sd)

	Float16[clamp(sd[i,j]/maxlen, -1, 1) for i=1:sw, j=1:sh], Vec2f0(w1, h1)
end

function GLAbstraction.render(glyph::Char, font, ta::TextureAtlas, face=DEFAULT_FONT_FACE)
	#select_font_face(cc, font)
	bitmap, extent = renderface(face, glyph, (256, 256))
	sd, real_size = sdistancefield(bitmap)
	rect = Rectangle(0, 0, size(sd)...)
    uv   = push!(ta.rectangle_packer, rect).area #find out where to place the rectangle
    uv == nothing && error("texture atlas is too small.") #TODO resize surface
    ta.images[uv] = sd
    uv, rect, extent, real_size
end

