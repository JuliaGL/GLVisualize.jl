
# This is the low-level text interface, which simply prepares the correct shader and cameras
function visualize(text::Texture{GLGlyph{Uint16}, 2}, ::Style{:default}, customization::Dict{Symbol, Any})
    @materialize! screen = customization
    camera = screen.orthographiccam
    data = @compat(Dict(
        :projectionview => camera.projectionview,
        :uvs            => Texture([UV(0,0),UV(0,0),UV(0,0),UV(0,0)]),
        :style          => Texture([RGBU8(0,0,0,1)]),
    ))
    shader = TemplateProgram(File(shaderdir, "text.vert"), File(shaderdir, "text.frag"))

    instanced_renderobject(data, data[:textlength], shader)
end
