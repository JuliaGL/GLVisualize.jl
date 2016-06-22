module FreeTypeAbstraction

using FreeType, GeometryTypes
using Compat
export newface
export renderface
export FontExtent
export kerning


immutable FontExtent{T}
    vertical_bearing    ::Vec{2, T}
    horizontal_bearing  ::Vec{2, T}

    advance             ::Vec{2, T}
    scale               ::Vec{2, T}
end
immutable FontFace
    name::String
end

import Base: ./, .*

.*{T, T2}(f::FontExtent{T}, scaling::Vec{2, T2}) = FontExtent(
    f.vertical_bearing * scaling[1],
    f.horizontal_bearing * scaling[2],
    f.advance .* scaling,
    f.scale .* scaling,
)
./{T, T2}(f::FontExtent{T}, scaling::Vec{2, T2}) = FontExtent(
    f.vertical_bearing ./ scaling,
    f.horizontal_bearing ./ scaling,
    f.advance ./ scaling,
    f.scale ./ scaling,
)

FontExtent(fontmetric::FreeType.FT_Glyph_Metrics, scale=64) = FontExtent(
    Vec{2, Float64}(fontmetric.vertBearingX, fontmetric.vertBearingY) / scale,
    Vec{2, Float64}(fontmetric.horiBearingX, fontmetric.horiBearingY) / scale,
    Vec{2, Float64}(fontmetric.horiAdvance, fontmetric.vertAdvance) / scale,
    Vec{2, Float64}(fontmetric.width, fontmetric.height) / scale
)


const FREE_FONT_LIBRARY = FT_Library[C_NULL]

function ft_init()
    global FREE_FONT_LIBRARY
    FREE_FONT_LIBRARY[1] != C_NULL && error("Freetype already initalized. init() called two times?")
    err = FT_Init_FreeType(FREE_FONT_LIBRARY)
    return err == 0
end

function ft_done()
    global FREE_FONT_LIBRARY
    FREE_FONT_LIBRARY[1] == C_NULL && error("Library == CNULL. FreeTypeAbstraction.done() called before init(), or done called two times?")
    err = FT_Done_FreeType(FREE_FONT_LIBRARY[1])
    FREE_FONT_LIBRARY[1] = C_NULL
    return err == 0
end


function newface(facename, faceindex::Real=0, ftlib=FREE_FONT_LIBRARY)
    face     = (FT_Face)[C_NULL]
    err     = FT_New_Face(ftlib[1], facename, Int32(faceindex), face)
    if err != 0
        error("FreeType could not load font $facename with error $err")
        return face[1]
    end
    face
end

setpixelsize(face, x, y) = setpixelsize(face, (x, y))

function setpixelsize(face, size)
    err = FT_Set_Pixel_Sizes(face[1], UInt32(size[1]), UInt32(size[2]))
    if err != 0
        error("Couldn't set the pixel size for font with error $err")
    end
end


function kerning(c1::Char, c2::Char, face::Array{Ptr{FreeType.FT_FaceRec},1}, divisor::Float32)
    i1 = FT_Get_Char_Index(face[], c1)
    i2 = FT_Get_Char_Index(face[], c2)
    kernVec = Array(FreeType.FT_Vector, 1)
    err = FT_Get_Kerning(face[], i1, i2, FreeType.FT_KERNING_DEFAULT, pointer(kernVec))
    if err != 0
        return zero(Vec{2, Float32})
    end
    return Vec{2, Float32}(kernVec[1].x / divisor, kernVec[1].y / divisor)
end

function loadchar(face, c::Char)
    err = FT_Load_Char(face[1], c, FT_LOAD_RENDER)
    @assert err == 0
end

function renderface(face, c::Char, pixelsize=(32,32))
    setpixelsize(face, pixelsize)
    faceRec = unsafe_load(face[1])
    loadchar(face, c)
    glyphRec    = unsafe_load(faceRec.glyph)
    @assert glyphRec.format == FreeType.FT_GLYPH_FORMAT_BITMAP
    return glyphbitmap(glyphRec.bitmap), FontExtent(glyphRec.metrics)
end

function getextent(face, c::Char, pixelsize)
    setpixelsize(face, pixelsize)
    faceRec = unsafe_load(face[1])
    loadchar(face, c)
    glyphRec = unsafe_load(faceRec.glyph)
    FontExtent(glyphRec.metrics)
end

function glyphbitmap(bmpRec::FreeType.FT_Bitmap)
    @assert bmpRec.pixel_mode == FreeType.FT_PIXEL_MODE_GRAY
    bmp = Array(UInt8, bmpRec.width, bmpRec.rows)
    row = bmpRec.buffer
    if bmpRec.pitch < 0
        row -= bmpRec.pitch * (rbmpRec.rows - 1)
    end

    for r = 1:bmpRec.rows
        srcArray = unsafe_wrap(Array, row, bmpRec.width)
        bmp[:, r] = srcArray
        row += bmpRec.pitch
    end
    return bmp
end

"""
Init and free c-lib
"""
function __init__()
    ft_init()
    atexit(ft_done)
end


end
