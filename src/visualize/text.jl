
visualize_default(::Union(Texture{Point2{Float32}, 2}, Array{Point2{Float32}, 2}, AbstractString), ::Style, kw_args...) = @compat(Dict(
    :primitive      => GLUVMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0)),
    :styles         => Texture([RGBAU8(0,0,0,1)]),
    :atlas          => get_texture_atlas()
))


function calc_position(glyphs, cc=CAIRO_CONTEXT)
    last_pos  = Point2{Float16}(0.0)
    positions = fill(Point2{Float16}(0.0), length(glyphs))
    for (i,glyph) in enumerate(glyphs)
        if '\n' == glyph
            if i<2
                last_pos = Point2{Float16}(last_pos.x, last_pos.y-50.0)
            else
                last_pos = Point2{Float16}(first(positions).x, positions[i-1].y-50.0)
            end
            positions[i] = last_pos
        else
            extent = FontExtent(cc, glyph)
            last_pos += Point2{Float16}(extent.advance)
            positions[i] = Point2{Float16}(last_pos.x+extent.bearing.x, last_pos.y-(extent.bearing.y+extent.scale.y))
        end
    end
    positions
end

function GLVisualize.visualize(text::AbstractString, s::Style, customizations=visualize_default(glyphs, s))
    positions   = Texture(reshape(calc_position(text), (length(text), 1)))
    glyphs      = map_fonts(text)
    glyphs      = Texture(reshape(map(x->GLSprite(x, 0), glyphs), (length(glyphs), 1)))
    visualize(glyphs, positions, s, customizations)  
end 

function GLVisualize.visualize(glyphs::Texture{GLSprite, 2}, positions::Texture{Point2{Float16},2},
        s::Style, customizations=visualize_default(glyphs, s))#, ::Style{:default}, customization::Dict{Symbol, Any})
    @materialize! screen, atlas = customizations
    camera = screen.orthographiccam
    data = merge(@compat(Dict(
        :positions           => positions,
        :glyphs              => glyphs,
        :projectionviewmodel => camera.projectionview,
        :uvs                 => atlas.attributes,
        :images              => atlas.images,
    )), collect_for_gl(GLMesh2D(Rectangle(0f0,0f0,1f0,1f0))))
    shader = TemplateProgram(
        File(GLVisualize.shaderdir, "util.vert"), 
        File(GLVisualize.shaderdir, "text.vert"), 
        File(GLVisualize.shaderdir, "text.frag"))

    instanced_renderobject(data, length(glyphs), shader)
end

