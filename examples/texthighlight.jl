using Colors, Highlights
using Highlights.Format
using Highlights.Tokens
using Highlights.Themes

import Compat: readstring

if !isdefined(Highlights.Themes, :has_fg)
    has_fg(style) = style.fg.active
    css2color(c) = RGBA{Float32}(c.r/255, c.g/255, c.b/255, 1)
else
    import Highlights.Themes: has_fg
    css2color(str) = parse(RGBA{Float32}, string("#", str))
end

function style2color(style, default)
    if has_fg(style)
        css2color(style.fg)
    else
        default
    end
end

function render_str(
        ctx::Format.Context, theme::Format.Theme
    )
    defaultcolor = if has_fg(theme.base)
        css2color(theme.base.fg)
    else
        RGBA(0f0, 0f0, 0f0, 1f0)
    end
    colormap = map(s-> style2color(s, defaultcolor), theme.styles)
    tocolor = Dict(zip(Tokens.__TOKENS__, colormap))
    colors = RGBA{Float32}[]
    io = IOBuffer()
    for token in ctx.tokens
        t = Tokens.__TOKENS__[token.value.value]
        str = SubString(ctx.source, token.first, token.last)
        print(io, str)
        append!(colors, fill(tocolor[t], length(str)))
    end
    takebuf_string(io), colors
end
function highlight_text(src::AbstractString, T = Themes.DefaultTheme)
    io = IOBuffer()
    render_str(
        Highlights.Compiler.lex(src, Lexers.JuliaLexer),
        Themes.theme(T)
    )
end
# T = Themes.GitHubTheme
# str, colors = highlight_text(GLVisualize.dir("src", "examples", "ExampleRunner.jl"), T)
# w.color=css2color(Themes.theme(T).base.bg)
# empty!(w);GLAbstraction.empty_shader_cache!()
# _view(visualize(str, color=colors))
#
#
#
# a = GLVisualize.get_texture_atlas()
# using FileIO
# img = GLAbstraction.gpu_data(a.images)
# x = img
# save(homedir()*"/test.png", map(Images.Clamp01NaN(x), x))
