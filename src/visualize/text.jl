visualize_default(::Union(Texture{GLSprite, 1}, AbstractString), ::Style, kw_args=Dict()) = Dict(
    :primitive     => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :styles        => Texture([RGBAU8(1.0,1.0,1.0,1.0)]),
    :atlas         => get_texture_atlas(),
    :technique     => :sprite
)

let TECHNIQUE_MAP = Dict(
        :sprite => Cint(1),
        :circle => Cint(2),
        :square => Cint(3),
    )
    global to_gl_technique
    to_gl_technique(technique) = TECHNIQUE_MAP[technique]
end

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
        s::Style, customizations=visualize_default(glyphs, s))

    @materialize! screen, atlas, primitive, model, technique = customizations
    camera = screen.orthographiccam
    data = merge(Dict(
        :positions           => positions,
        :glyphs              => glyphs,
        :uvs                 => atlas.attributes,
        :images              => atlas.images,
        :style_index         => style_index,
        :projectionviewmodel => lift(*, camera.projectionview, model),
        :technique           => lift(to_gl_technique, technique)

    ), collect_for_gl(primitive), customizations)

    shader = TemplateProgram(
        File(GLVisualize.shaderdir, "util.vert"), 
        File(GLVisualize.shaderdir, "text.vert"), 
        File(GLVisualize.shaderdir, "distance_shape.frag")
    )
    instanced_renderobject(data, length(glyphs), shader)
end


cursor_visible(range) = isempty(range) && first(range) > 0
cool_color(i)         = RGBA(sin(i), 1f0, 1f0, 1f0)
function cursor(positions, screen, range)
    camera = screen.orthographiccam
    atlas = GLVisualize.get_texture_atlas()
    data = merge(Dict(
        :visible             => lift(cursor_visible, range),
        :offset              => lift(Cint, lift(first, range)),
        :color               => lift(cool_color, bounce(0f0:0.2f0:1f0)),
        :positions           => positions,
        :glyph               => Sprite{GLuint}(GLVisualize.get_font!('|')),
        :uvs                 => atlas.attributes,
        :images              => atlas.images,
        :projectionviewmodel => camera.projectionview,

    ), collect_for_gl(GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0))))

    shader = TemplateProgram(
        File(GLVisualize.shaderdir, "util.vert"), 
        File(GLVisualize.shaderdir, "text_single.vert"), 
        File(GLVisualize.shaderdir, "text.frag")
    )
    std_renderobject(data, shader)
end
export cursor


function add_edit(inputs, background, text, t)
    selection = inputs[:selection]
    selection = lift(last, foldl(move_cursor, 
                    (selection.value, selection.value), 
                    selection, 
                    inputs[:arrow_navigation], 
                    Input(t)))
    is_text(x) = x[2][1] == background.id || x[2][1] == text.id
    selection  = keepwhen(
        lift(is_text, inputs[:mousedragdiff_objectid]), 
        0:0, selection
    )

    foldl(visualize_selection, 0:0, selection, Input(background[:style_index]))
    selection
end
export add_edit