
visualize_default(::Union(Texture{Point2{Float32}, 2}, Array{Point2{Float32}, 2}, AbstractString), ::Style, kw_args...) = @compat(Dict(
    :primitive     => GLMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :styles        => Texture([RGBAU8(0,0,0,1)]),
    :atlas         => get_texture_atlas()
))



function calc_position(glyphs)
    const PF16 = Point2{Float16}
    global FONT_EXTENDS
    last_pos  = PF16(0.0)
    positions = fill(PF16(0.0), length(glyphs))
    lastglyph = first(glyphs)
    for (i,glyph) in enumerate(glyphs)
        extent = FONT_EXTENDS[glyph]
        if lastglyph == '\n'
            if i<2
                last_pos = PF16(last_pos.x, last_pos.y-extent.advance.y)
            else
                last_pos = PF16(first(positions).x, positions[i-1].y-extent.advance.y)
            end
            positions[i] = last_pos
        else
            last_pos += PF16(extent.advance.x, 0)
            finalpos = last_pos
            #finalpos = PF16(last_pos.x+extent.horizontal_bearing.x, last_pos.y-(extent.scale.y-extent.horizontal_bearing.y))
            (i>1) && (finalpos += PF16(kerning(lastglyph, glyph, DEFAULT_FONT_FACE, 64f0)))
            positions[i] = finalpos
        end
        lastglyph = glyph
    end
    positions
end

function GLVisualize.visualize(text::AbstractString, s::Style, customizations=visualize_default(glyphs, s))
    glyphs      = texture_buffer(map(GLSprite, map_fonts(text)))
    positions   = texture_buffer(calc_position(text))
    style_index = texture_buffer(fill(GLSpriteStyle(0,0), length(text)))

    visualize(glyphs, positions, style_index, s, customizations)  
end 

function GLVisualize.visualize(
        glyphs::Texture{GLSprite, 1}, 
        positions::Texture{Point2{Float16},1},
        style_index::Texture{GLSpriteStyle, 1}, 
        s::Style, customizations=visualize_default(glyphs, s))#, ::Style{:default}, customization::Dict{Symbol, Any})
    
    @materialize! screen, atlas, primitive, model = customizations
    camera = screen.orthographiccam
    data = merge(Dict(
        :positions           => positions,
        :glyphs              => glyphs,
        :uvs                 => atlas.attributes,
        :images              => atlas.images,
        :style_index         => style_index,
        :projectionviewmodel => lift(*, camera.projectionview, model),

    ), collect_for_gl(primitive), customizations)

    shader = TemplateProgram(
        File(GLVisualize.shaderdir, "util.vert"), 
        File(GLVisualize.shaderdir, "text.vert"), 
        File(GLVisualize.shaderdir, "text.frag")
    )

    instanced_renderobject(data, length(glyphs), shader)
end

