
type TextureAtlas
    rectangle_packer::RectanglePacker
    mapping         ::Dict{Any, Int} # styled glyph to index in sprite_attributes
    index           ::Int
    images          ::Texture{Float16, 2}
    attributes      ::Vector{Vec4f0}
    scale           ::Vector{Vec2f0}
    extent          ::Vector{FontExtent{Float64}}

    function TextureAtlas(initial_size=(4096, 4096))

        images = Texture(fill(Float16(0.0), initial_size...), minfilter=:linear, magfilter=:linear)

        new(
            RectanglePacker(SimpleRectangle(0, 0, initial_size...)),
            Dict{Any, Int}(),
            1,
            images,
            Vec4f0[],
            Vec2f0[],
            FontExtent{Float64}[]
        )
    end
end



begin #basically a singleton for the textureatlas
const local TEXTURE_ATLAS = TextureAtlas[]
reset_texture_atlas!() = empty!(TEXTURE_ATLAS)
function get_texture_atlas()
    not_initilized = isempty(TEXTURE_ATLAS)
    if not_initilized
        fn = assetpath("fonts", "DejaVuSansMono.ttf")
        global DEFAULT_FONT_FACE = newface(fn)
        atlas = push!(TEXTURE_ATLAS, TextureAtlas())[] # initialize only on demand
        for c in '\u0000':'\u00ff' #make sure all ascii is mapped linearly
            insert_glyph!(atlas, c, DEFAULT_FONT_FACE)
        end
        return atlas
    else
        return TEXTURE_ATLAS[]
    end
end
end

function glyph_index!(atlas::TextureAtlas, c::Char, font)
    if c < '\u00ff' && font == DEFAULT_FONT_FACE # characters up to '\u00ff'(255), are directly mapped for default font
        Int(c)+1
    else #others must be looked up, since they're inserted when used first
        return insert_glyph!(atlas, c, font)
    end
end

glyph_scale!(c::Char) = glyph_scale!(get_texture_atlas(), c, DEFAULT_FONT_FACE)
glyph_uv_width!(c::Char) = glyph_uv_width!(get_texture_atlas(), c, DEFAULT_FONT_FACE)

function glyph_uv_width!(atlas::TextureAtlas, c::Char, font)
    atlas.attributes[glyph_index!(atlas, c, font)]
end
function glyph_scale!(atlas::TextureAtlas, c::Char, font)
    atlas.scale[glyph_index!(atlas, c, font)]
end
function glyph_extent!(atlas::TextureAtlas, c::Char, font)
    atlas.extent[glyph_index!(atlas, c, font)]
end

function bearing(extent)
     Point2f0(extent.horizontal_bearing[1], -(extent.scale[2]-extent.horizontal_bearing[2]))
end
function glyph_bearing!{T}(atlas::TextureAtlas, c::Char, font, scale::T)
    T(bearing(atlas.extent[glyph_index!(atlas, c, font)])) .* scale
end
function glyph_advance!{T}(atlas::TextureAtlas, c::Char, font, scale::T)
    T(atlas.extent[glyph_index!(atlas, c, font)].advance) .* scale
end


insert_glyph!(atlas::TextureAtlas, glyph::Char, font) = get!(atlas.mapping, (glyph, font)) do
    uv, rect, extent, width_nopadd = render(atlas, glyph, font)
    tex_size       = Vec2f0(size(atlas.images))
    uv_start       = Vec2f0(uv.x, uv.y)
    uv_width       = Vec2f0(uv.w, uv.h)
    real_heightpx  = width_nopadd[2]
    halfpadding    = (uv_width - width_nopadd) / 2f0
    real_start     = uv_start + halfpadding # include padding
    relative_start = real_start ./ tex_size # use normalized texture coordinates
    relative_width = (real_start+width_nopadd) ./ tex_size

    bearing         = extent.horizontal_bearing
    uv_offset_width = Vec4f0(relative_start..., relative_width...)
    i               = atlas.index
    push!(atlas.attributes, uv_offset_width)
    push!(atlas.scale, Vec2f0(width_nopadd))
    push!(atlas.extent, extent)
    atlas.index = i+1
    return i
end

function sdistancefield(img, min_size=32)
    w, h = size(img)
    w1, h1 = w, h
    restrict_steps = 2
    halfpad = 2*(2^restrict_steps) # padd so that after restrict it comes out as roughly 4 pixel
    w, h = w+2halfpad, h+2halfpad #pad this, to avoid cuttoffs
    in_or_out = Bool[begin
        x, y = i-halfpad, j-halfpad
        if checkbounds(Bool, img, x,y)
            img[x,y] >= 1.0
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

function GLAbstraction.render(atlas::TextureAtlas, glyph::Char, font)
    #select_font_face(cc, font)
    if glyph == '\n' # don't render  newline
        glyph = ' '
    end
    bitmap, extent = renderface(font, glyph, (128, 128))

    sd, width_nopadd, scaling_factor = sdistancefield(bitmap)
    if min(size(bitmap)...) > 0
        s = width_nopadd ./ Vec2f0(size(bitmap))
        extent = extent .* s
    else
        extent = extent ./ Vec2f0(2^2)
    end
    rect = SimpleRectangle(0, 0, size(sd)...)
    uv   = push!(atlas.rectangle_packer, rect) #find out where to place the rectangle
    uv == nothing && error("texture atlas is too small. Resizing not implemented yet. Please file an issue at GLVisualize if you encounter this") #TODO resize surface
    atlas.images[uv.area] = sd
    uv.area, rect, extent, width_nopadd
end
