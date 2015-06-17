visualize_default(::Union(GPUVector{GLSprite}, AbstractString), ::Style, kw_args=Dict()) = Dict(
    :primitive          => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :styles             => Texture([RGBAU8(1.0,1.0,1.0,1.0)]),
    :atlas              => get_texture_atlas(),
    :technique          => :sprite,
    :preferred_camera   => :orthographic_pixel
)

let TECHNIQUE_MAP = Dict(
        :sprite => Cint(1),
        :circle => Cint(2),
        :square => Cint(3),
    )
    global to_gl_technique
    to_gl_technique(technique) = TECHNIQUE_MAP[technique]
end


function visualize(text::AbstractString, s::Style, customizations=visualize_default(text, s))
    glyphs      = GPUVector(texture_buffer(process_for_gl(text)))
    positions   = GPUVector(texture_buffer(calc_position(glyphs)))
    style_index = GPUVector(texture_buffer(fill(GLSpriteStyle(0,0), length(text))))
    visualize(glyphs, positions, style_index, s, customizations)  
end 

function visualize(
        glyphs      ::GPUVector{GLSprite}, 
        positions   ::GPUVector{Point2{Float16}},
        style_index ::GPUVector{GLSpriteStyle}, 
        s::Style, customizations=visualize_default(glyphs, s))

    @materialize! atlas, primitive, technique = customizations
    data = merge(Dict(
        :positions           => positions,
        :glyphs              => glyphs,
        :uvs                 => atlas.attributes,
        :images              => atlas.images,
        :style_index         => style_index,
        :technique           => lift(to_gl_technique, technique)
    ), collect_for_gl(primitive), customizations)

    shader = TemplateProgram(
        File(GLVisualize.shaderdir, "util.vert"), 
        File(GLVisualize.shaderdir, "text.vert"), 
        File(GLVisualize.shaderdir, "distance_shape.frag")
    )
    instanced_renderobject(data, glyphs, shader, Input(AABB{Float32}(AABB(gpu_data(positions)))))
end


cursor_visible(range) = isempty(range) && first(range) > 0
cool_color(i)         = RGBA(sin(i), 1f0, 1f0, 1f0)
function cursor(positions, range)
    atlas = GLVisualize.get_texture_atlas()
    data = merge(Dict(
        :model               => eye(Mat4),
        :visible             => lift(cursor_visible, range),
        :offset              => lift(Cint, lift(first, range)),
        :color               => lift(cool_color, bounce(0f0:0.2f0:1f0)),
        :positions           => positions,
        :glyph               => Sprite{GLuint}(GLVisualize.get_font!('|')),
        :uvs                 => atlas.attributes.buffer,
        :images              => atlas.images,
    ), collect_for_gl(GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0))))

    shader = TemplateProgram(
        File(GLVisualize.shaderdir, "util.vert"), 
        File(GLVisualize.shaderdir, "text_single.vert"), 
        File(GLVisualize.shaderdir, "text.frag")
    )
    std_renderobject(data, shader)
end
export cursor


function add_edit(inputs, background, text, text_selection)
    selection = inputs[:selection]
    selection = lift(
        last, 
        foldl(
            move_cursor, 
            (selection.value, selection.value), 
            inputs[:arrow_navigation], selection,
            text_selection
        )
    )
    is_text(x) = x[2][1] == background.id || x[2][1] == text.id
    selection  = keepwhen(
        lift(is_text, inputs[:mousedragdiff_objectid]), 
        0:0, selection
    )
    selection
end
export add_edit
