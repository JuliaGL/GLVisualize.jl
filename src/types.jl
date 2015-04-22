#########################################################################################################
#=
Glyph type for Text rendering.
It doesn't offer any functionality, and is only used for multiple dispatch.
=#
immutable GLGlyph{T} <: FixedVector{T, 4}
  glyph::T
  line::T
  row::T
  style_group::T
end

function GLGlyph(glyph::Integer, line::Integer, row::Integer, style_group::Integer)
  if !isascii(char(glyph))
    glyph = char('1')
  end
  GLGlyph{Uint16}(uint16(glyph), uint16(line), uint16(row), uint16(style_group))
end
function GLGlyph(glyph::Char, line::Integer, row::Integer, style_group::Integer)
  if !isascii(glyph)
    glyph = char('1')
  end
  GLGlyph{Uint16}(uint16(glyph), uint16(line), uint16(row), uint16(style_group))
end

GLGlyph() = GLGlyph(' ', typemax(Uint16), typemax(Uint16), 0)


#########################################################################################################

