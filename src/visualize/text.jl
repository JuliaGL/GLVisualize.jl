#=
immutable Glyph{T} <: FixedVector{T, 2}
	char::T
	style::T
end


typealias GLGlyph Glyph{Uint16}
# This is the low-level text interface, which simply prepares the correct shader and cameras
function visualize(glyphs::Texture{GLGlyph, 2}, positions::Texture{Point2{Float16}}, atlas::TextureAtlas)#, ::Style{:default}, customization::Dict{Symbol, Any})
    @materialize! screen = customization
    camera = screen.orthographiccam
    data = @compat(Dict(
    	:positions 		=> positions,
    	:glyphs 		=> glyphs,
        :projectionview => camera.projectionview,
        :uvs            => atlas.,
        :styles         => Texture([RGBU8(0,0,0,1)]),
    ))
    shader = TemplateProgram(File(shaderdir, "text.vert"), File(shaderdir, "text.frag"))

    instanced_renderobject(data, data[:textlength], shader)
end

=#