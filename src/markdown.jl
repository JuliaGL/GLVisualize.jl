# This file is a part of Julia. License is MIT: http://julialang.org/license

type Text
    text
    positions
    colors
    scales
end
length(rt::Text) = length(rt.text)
function sizehint!(t:Text, size::Int)
    for elem in (:text, :position, :colors, :scales, :fonts)
        sizehint!(t.(elem), size)
    end
    nothing
end
type RichText
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
    positions = get_iter(()->positions(text, text2), style, positions)
    colors    = get_iter(()->font_color(text),       style, colors)
    fonts     = get_iter(()->font(text),             style, colors)
    sizes     = get_iter(()->font_size(text),        style, colors)

    sizehint!(text, length(text)+length(text2))
    for elem in zip(text2, positions, colors, fonts, sizes)
        push!(text.text, elem)
    end
end

"""
Inserts code with highlighting
"""
function insert!(text::RichText, code::Code, 
        position=text.cursor, 
        color_scheme=color_scheme(text, code)
    )

end

"""
Inlines any `object` in `area` at `position`.
"""
function insert!(text::RichText, object, position=text.cursor, area=nothing)

end
const RichtTextValues = FixedKeyDict{Tuple{
    Val{:text}, Val{:positions}, Val{:colors}, Val{:scales}
}}


function push!(text::RichText, values::RichtTextValues)
    for props in zip(text2, positions, colors, fonts, sizes)
        push!(text, props)
    end
    nothing
end

type ColorScheme{Object}
    x::Dict
end

"""
Tree structure, to allow for hierarchical coloring. 
Each key holds either a key to a Color, or a new key into the Dict.
Keys are symbols, so values must not be symbols, as they will then be used for lookup.
"""
immutable ColorScheme
    container::Dict{Symbol, Any}
end
function ColorScheme(values::Vector)
    # we're mega hip and make every value a signal,
    # so that one can interactively change the colorscheme
    dict = Dict{Symbo, Any}(map(values) do pair
        key, value = pair
        if !isa(value, Symbol) && !isa(value, Signal)
            return key => Signal(value)
        end
        key=>value
    end)
    ColorScheme(dict)
end
function Base.setindex!(x::ColorScheme, key::Symbol, value)
    x.container[key] = value
end
function Base.get(td::ColorScheme, key::Symbol, default)
    circle_check = Set()
    # values are either new keys, or values.
    # Keys are always symbols, values never. So we iterate as long as the value is a Symbol
    while !isa(key, Symbol)
        haskey(td, key) || return default # if doesn't contain key, return default
        if value in circle_check # check if we visited key already
            error("Circle detected for value: $value, in tree dict: $td")
        end
        push!(circle_check, key)
        key = td.container[key]
    end
    # found non symbol, must be a value!
    key
end


function color_scheme(code::Code)
    code.language != "Julia" && error("only Julia code supported. Found: $code.language")
    ColorScheme([
        :Any => RGB(0,0,0),
        :Keyword => RGB(0,0,0),
        :Scope => RGB(0,0,0),
        :Comment => RGB(0.9, 0.9, 0.9),
        :Number => RGB(0.9, 0.9, 0.9),
        :FloatingPoint => RGB(0.9, 0.9, 0.9),
        :Integer => RGB(0.9, 0.9, 0.9),
        :Operator => RGB(1,0,0),
        :Call => RGB(0,0,1),
        :String => RGB(0.9, 0.9, 0.9),
        :symbol => RGB(0.8, 0.8, 0.1),

        :macro_call => :Call,
        :call => :Call,

        :ControlFlow => :Keyword,
        :function => :Keyword,
        :macro => :Keyword,
        :do => :Keyword,
        :OPKeyword => :Keyword,
        :(::) => :OPKeyword,
        symbol(",") => :OPKeyword,
        symbol(";") => :OPKeyword,
        symbol(":") => :OPKeyword,
        symbol("...") => :OPKeyword,
        :end => :Scope,
        :while => :ControlFlow,
        :continue => :ControlFlow,
        :try => :ControlFlow,
        :catch => :ControlFlow,
        :finally => :ControlFlow,
        :break => :ControlFlow,
        :for => :ControlFlow,
        :if => :ControlFlow,
        :else => :ControlFlow,
        :elseif => :ControlFlow,
        :(&&) => :ControlFlow,
        :(||) => :ControlFlow,
        :ArrayScope => :Scope,
        symbol("(") => :ArrayScope,
        symbol(")") => :ArrayScope,
        symbol("[") => :ArrayScope,
        symbol("]") => :ArrayScope,
        :Curly       => :Scope,
        symbol("{") => :Curly,
        symbol("}") => :Curly
    ])
end

token2symbol(token::Lexer.AbstractToken) = token2symbol(token.val)
token2symbol(token::Char) = symbol(token)
token2symbol(token::Number) = :Number
token2symbol(token::FloatingPoint) = :FloatingPoint
token2symbol(token::Integer) = :Integer
token2symbol(token) = symbol(string(token))

function token2color(colorscheme, token)
    sym = token2symbol(token)
    get(colorscheme, sym, get(colorscheme, :Any, RGB(0.,0.,0.)))
end
function tkstream2color(colorscheme, tokenstream)
    string_started = false
    symbol_started = false
    macro_call_started = false
    last_token = peek(tokenstream)
    while !Lexer.eof(token)
        token2color(token)
    end
end


# Block elements

printmd(io::IO, md::MD) = printmd(io, md.content)


function printmd(io::RichText, content::Vector)
    for md in content
        printmd(io, md)
        println(io)
    end
end


function printmd{l}(io::RichText, header::Header{l})
    withtag(io, "h$l") do
        htmlinline(io, header.text)
    end
end

function printmd(io::RichText, code::Code)
    insert!(io, code)
end

function printmd(io::RichText, md::Paragraph)
    withtag(io, :p) do
        htmlinline(io, md.content)
    end
end

function printmd(io::RichText, md::BlockQuote)
    withtag(io, :blockquote) do
        println(io)
        printmd(io, md.content)
    end
end

function printmd(io::RichText, md::List)
    withtag(io, md.ordered ? :ol : :ul) do
        for item in md.items
            println(io)
            withtag(io, :li) do
                htmlinline(io, item)
            end
        end
        println(io)
    end
end

function printmd(io::RichText, md::HorizontalRule)
    insert!(io, Line(Point2f0(0), Point2f0(area.w, 0)))
end


# Inline elements

function htmlinline(io::IO, content::Vector)
    for x in content
        htmlinline(io, x)
    end
end

function htmlinline(io::IO, code::Code)
    withtag(io, :code) do
        htmlesc(io, code.code)
    end
end

function htmlinline(io::IO, md::Union{Symbol, AbstractString})
    htmlesc(io, md)
end

function htmlinline(io::IO, md::Bold)
    withtag(io, :strong) do
        htmlinline(io, md.text)
    end
end

function htmlinline(io::IO, md::Italic)
    withtag(io, :em) do
        htmlinline(io, md.text)
    end
end

function htmlinline(io::IO, md::Image)
    tag(io, :img, :src=>md.url, :alt=>md.alt)
end

function htmlinline(io::IO, link::Link)
    withtag(io, :a, :href=>link.url) do
        htmlinline(io, link.text)
    end
end

function htmlinline(io::IO, br::LineBreak)
    tag(io, :br)
end
