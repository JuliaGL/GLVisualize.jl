immutable Sprite{N, T} <: FixedVector{N, T}
	#attribute_id::T # lookup attribute_id for attribute texture
	_::NTuple{N, T}
end
immutable SpriteStyle{N, T} <: FixedVector{N, T}
	#color_id::T # lookup attribute_id for attribute texture
	#technique::T
	_::NTuple{N, T}
end


immutable SpriteAttribute{N, T} <: FixedVector{N, T}
	_::NTuple{N, T}
	#u::T
	#v::T
	#x_scale::T
	#y_scale::T
end


typealias GLSpriteAttribute SpriteAttribute{4, Float16}
typealias GLSprite Sprite{1, UInt32}
typealias GLSpriteStyle SpriteStyle{2, UInt16}
const GL_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE

type TextureAtlas
	rectangle_packer::RectanglePacker
	mapping 		::Dict{Any, Int} # styled glyph to index in sprite_attributes
	index 			::Int
	images 			::Texture{Float16, 2}
    attributes      ::Vector{Vec4f0}
	scale 		    ::Vector{Vec2f0}
	# sprite_attributes layout
	# can be compressed quite a bit more
	# ID Vertex1     Vertex2     Vertex3     Vertex4
	# 0  [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] [u,v,xs,ys] # uv -> rectangular section in TextureAtlas
	# 1  ...
	# .
	# .
	# .
	function TextureAtlas(initial_size=(4096, 4096))
        #@time( (data = open(joinpath(dirname(@__FILE__), "texture_atlas.bin")) do io
        #    deserialize(io)
        #end))
		#images = Texture(data, minfilter=:linear, magfilter=:linear)
		images = Texture(fill(Float16(0.0), initial_size...), minfilter=:linear, magfilter=:linear)
		#glBindTexture(GL_TEXTURE_2D, images.id)
		#glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16)
		#glBindTexture(GL_TEXTURE_2D, 0)

		new(
			RectanglePacker(SimpleRectangle(0, 0, initial_size...)),
			Dict{Any, Int}(),
			1,
			images,
			Vec4f0[],
            Vec2f0[]
		)
	end
end



begin #basically a singleton for the textureatlas
const local TEXTURE_ATLAS = TextureAtlas[]
get_texture_atlas() = isempty(TEXTURE_ATLAS) ? push!(TEXTURE_ATLAS, TextureAtlas())[] : TEXTURE_ATLAS[] # initialize only on demand
end
function get_uv_offset_width!(c::Char;
        font          = DEFAULT_FONT_FACE,
        texture_atlas = get_texture_atlas()
    )
    texture_atlas.attributes[get_font!(c, font, texture_atlas)+1]
end

function get_font_scale!(c::Char;
        font          = DEFAULT_FONT_FACE,
        texture_atlas = get_texture_atlas()
    )
    texture_atlas.scale[get_font!(c, font, texture_atlas)+1]
end

Base.get!(texture_atlas::TextureAtlas, glyph::Char, font) = get!(texture_atlas.mapping, (glyph, font)) do
	uv, rect, extent, real_width = render(glyph, font, texture_atlas)
	tex_size 			= Vec2f0(size(texture_atlas.images))
	uv_start 			= Vec2f0(uv.x, uv.y)
	uv_width 			= Vec2f0(uv.w, uv.h)
	real_heightpx 		= real_width[2]
	halfpadding 		= (uv_width - real_width) / 2f0
	real_start 			= uv_start + halfpadding # include padding
	relative_start 		= real_start ./ tex_size # use normalized texture coordinates
	relative_width 		= (real_start+real_width) ./ tex_size

	bearing 			= extent.horizontal_bearing
	uv_offset_width 	= Vec4f0(relative_start..., relative_width...)
	i = texture_atlas.index
	push!(texture_atlas.attributes, uv_offset_width)
    push!(texture_atlas.scale, Vec2f0(real_width))
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


function sdistancefield(img, min_size=32)
	w, h = size(img)
	w1, h1 = w, h
	restrict_steps = 2
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
		w1, h1 = Images.restrict_size(w1), Images.restrict_size(h1)
		sd = Images.restrict(sd) #downsample
	end
	sz = Vec2f0(size(img))
	maxlen = norm(sz)
	sw, sh = size(sd)

	Float16[clamp(sd[i,j]/maxlen, -1, 1) for i=1:sw, j=1:sh], Vec2f0(w1, h1), (2^restrict_steps)
end

function GLAbstraction.render(glyph::Char, font, ta::TextureAtlas, face=DEFAULT_FONT_FACE)
	#select_font_face(cc, font)
	bitmap, extent = renderface(face, glyph, (128, 128))
	sd, real_size, scaling_factor = sdistancefield(bitmap)
	if min(size(bitmap)...) > 0
		s = real_size ./ Vec2f0(size(bitmap))
		extent = extent .* s
	else
		extent = extent ./ Vec2f0(2^2)
	end
	rect = SimpleRectangle(0, 0, size(sd)...)
    uv   = push!(ta.rectangle_packer, rect).area #find out where to place the rectangle
    uv == nothing && error("texture atlas is too small.") #TODO resize surface
    ta.images[uv] = sd
    uv, rect, extent, real_size
end
