using FreeType

type Glyph
    char::Char
    box::Rect{Int}
    origin::Vec2
    advance::Vec2
end

type Font
    family::String
    style::String
    size::Vec2
    lineDistance::Float32
    ascent::Float32
    descent::Float32
    glyphs::Dict{Char, Glyph}
    kerning::Dict{(Char, Char), Vec2{Float32}}
    bitmap::Array{Uint8, 2}
    fallbackGlyph::Glyph

    Font(family, style, sizeX, sizeY, lineDistance, ascent, descent, bmpWidth, bmpHeight) =
        new(family, style, Vec2{Float32}(sizeX, sizeY), lineDistance, ascent, descent, Dict{Char, Glyph}(), Dict{(Char, Char), Vec2{Float32}}(), zeros(Uint8, bmpWidth, bmpHeight))
end

Font(family, style, sizeX, sizeY, lineDistance, ascent, descent, maxCharWidth, maxCharHeight, charCount) =
    Font(family, style, sizeX, sizeY, lineDistance, ascent, descent, font_bitmap_size(maxCharWidth + 1, maxCharHeight + 1, charCount)...)


function addkerning(font::Font, c1::Char, c2::Char, distance::Vec2{Float32})
    @assert haskey(font.glyphs, c1) && haskey(font.glyphs, c2)
    @assert !haskey(font.kerning, (c1, c2))
    font.kerning[(c1, c2)] = distance
end

function adding_done(font::Font)
    # maybe calculate the real ascent and descent from the glyph data as well, since the FreeType data can be off
    corner = one(Vec2{Int})
    for g in values(font.glyphs)
        corner = max(corner, g.box.max)
    end
    corner += one(Vec2{Int})
    if corner.x < size(font.bitmap, 1) || corner.y < size(font.bitmap, 2)
        font.bitmap = font.bitmap[1:corner.x, 1:corner.y]
    end
end


function drawtext(drawRect::Function, font::Font, cursor::TextCursor, s::String)
    for c in s
        glyph = get(font.glyphs, c, font.fallbackGlyph)
        if cursor.lastChar != 0
            cursor.pos += get(font.kerning, (cursor.lastChar, c), zero(Vec2{Float32}))
        end
        drawRect(cursor.pos - glyph.origin, font.bitmap, glyph.box)
        cursor.pos += glyph.advance
        cursor.lastChar = c
    end
end

function textbox(font::Font, cursor::TextCursor, s::String)
    tempCursor = TextCursor(cursor)
    boxMax = rect(Float32)
    drawtext(font, tempCursor, s) do pos, bmp, box
        boxMax.min = min(boxMax.min, pos)
        boxMax.max = max(boxMax.max, pos + size(box))
    end
    return boxMax
end

fontname(font::Font) = "$(font.family)_$(font.style)($(font.size.x)x$(font.size.y))"

const ftLib = (FT_Library)[C_NULL]

function init()
    global ftLib
    @assert ftLib[1] == C_NULL
    err = FT_Init_FreeType(ftLib)
    return err == 0
end

function done()
    global ftLib
    @assert ftLib[1] != C_NULL
    err = FT_Done_FreeType(ftLib[1])
    ftLib[1] = C_NULL
    return err == 0
end



function newface(ftlib, facename, faceindex::Real=0)
	face 	= (FT_Face)[C_NULL]
    err 	= FT_New_Face(ftlib[1], facename, int32(faceindex), face)
    if err != 0
        info("Couldn't load font $faceName with error $err")
        return face[1]
    end
    face
end
setpixelsize(face, x, y) = setpixelsize(face, (x, y))
function setpixelsize(face, size)
	err = FT_Set_Pixel_Sizes(face[1], uint32(size[1]), uint32(size[2]))
    if err != 0
        info("Couldn't set the pixel size for font $faceName with error $err")
    end
end

function loadfont(faceName::String; sizeXY::(Real, Real) = (32, 32), faceIndex::Real = 0, chars = '\u0000':'\u00ff')
    face = (FT_Face)[C_NULL]
    err = FT_New_Face(ftLib[1], faceName, int32(faceIndex), face)
    if err != 0
        info("Couldn't load font $faceName with error $err")
        return nothing
    end

    err = FT_Set_Pixel_Sizes(face[1], uint32(sizeXY[1]), uint32(sizeXY[2]))
    font = nothing
    if err != 0
        info("Couldn't set the pixel size for font $faceName with error $err")
    else
        faceRec = unsafe_load(face[1])

        maxCharWidth, maxCharHeight = max_glyph_size(face[1], faceRec, chars)

        emScale = float32(sizeXY[2]) / faceRec.units_per_EM
        lineDist = round(faceRec.height * emScale)
        ascent = round(faceRec.ascender * emScale)
        descent = round(faceRec.descender * emScale)

        font = Font(bytestring(faceRec.family_name),
                    bytestring(faceRec.style_name),
                    sizeXY[1], sizeXY[2],
                    lineDist, ascent, descent,
                    maxCharWidth, maxCharHeight, length(chars))

        # load glyphs
        charPos = GlyphPosition()
        for c in chars
            err = FT_Load_Char(face[1], c, FT_LOAD_RENDER)
            @assert err == 0
            glyphRec = unsafe_load(faceRec.glyph)
            @assert glyphRec.format == FreeType.FT_GLYPH_FORMAT_BITMAP
            glyphBmp = glyph_bitmap(glyphRec.bitmap)

            addglyph(font, c, glyphBmp,
                     Vec2{Float32}(-glyphRec.bitmap_left, glyphRec.bitmap_top),
                     Vec2{Float32}(glyphRec.advance.x / 64f0, glyphRec.advance.y / 64f0),
                     charPos)
        end

        # query kerning info
        if faceRec.face_flags & FreeType.FT_FACE_FLAG_KERNING != 0
            kernDivisor = (faceRec.face_flags & FreeType.FT_FACE_FLAG_SCALABLE != 0) ? 64f0 : 1f0
            for c1 in chars, c2 in chars
                kerning = get_kerning(face[1], c1, c2, kernDivisor)
                if kerning != zero(Vec2)
                    addkerning(font, c1, c2, kerning)
                end
            end
        end

        adding_done(font)
    end

    err = FT_Done_Face(face[1])
    @assert err == 0
    return font
end

