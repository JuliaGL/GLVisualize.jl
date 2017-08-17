mutable struct Text
    atlas
    offsets
    uvs
    positions
    colors
    scales
end
length(rt::Text) = length(rt.text)
function sizehint!(t:Text, size::Int)
    for elem in (:text, :positions, :colors, :scales, :uvs, :offsets)
        sizehint!(getfield(t, elem), size)
    end
    nothing
end
const TextDefault = Dict(
    :atlas => GLVisualize.get_texture_atlas()
    :color => RGBA{Float32}(0,0,0,1)
    :scale => Vec2f0(50)
    :font => GLVisualize.defaultfont()
)

mutable struct RichText
    defaults::FixedKeyDict
    text::Text
    inlined_objects::Vector
    links::Vector
    cursor
end
function sizehint!(t:RichText, size::Int)
    sizehint!(t.text, size)
    nothing
end
length(rt::RichtText) = length(rt.text)
make_iter(x) = repeat(x)
make_iter(x::AbstractArray) = x

function get_iter(defaultfunc, dictlike, key)
    make_iter(get(defaultfunc, dictlike, key))
end

"""
Inserts text at [`position`] with `style`
"""
function insert!(text::RichText, text2::AbstractString, position=text.cursor, style=EMPTY_STYLE)
    positions = get_iter(()->positions(text, text2), style, :positions)
    offsets   = get_iter(()->offsets(text, text2),   style, :offsets)
    colors    = get_iter(()->font_color(text),       style, :colors)
    fonts     = get_iter(()->font(text),             style, :fonts)
    sizes     = get_iter(()->font_size(text),        style, :fontsizes)

    for elem in zip(text2, positions, colors, fonts, sizes)
        push!(text.text, elem)
    end
end

"""
Inserts code with highlighting
"""
function insert!(text::RichText, code::Code,
        position = text.cursor,
        color_scheme = color_scheme(text, code)
    )

end

"""
Inlines any `object` in `area` at `position`.
"""
function insert!(text::RichText, object, position = text.cursor, area = nothing)

end


function push!(text::RichText, values::RichtTextValues)
    for props in zip(text2, positions, colors, fonts, sizes)
        push!(text, props)
    end
    nothing
end
