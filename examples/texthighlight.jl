using Colors, Highlights
using Highlights.Format
using Highlights.Tokens
using Highlights.Themes

css2color(str) = parse(RGBA{Float32}, string("#", str))
function style2color(style, default)
    if Themes.has_fg(style) && !isempty(style.fg)
        css2color(style.fg)
    else
        default
    end
end
function render_str(
        ctx::Format.Context, theme::Format.Theme
    )
    defaultcolor = if Themes.has_fg(theme.base)
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
        append!(colors, repeated(tocolor[t], length(str)))
    end
    takebuf_string(io), colors
end
function highlight_text(path, T = Themes.DefaultTheme)
    src = readstring(path)
    io = IOBuffer()
    render_str(
        Highlights.Compiler.lex(src, Lexers.JuliaLexer),
        Themes.theme(T)
    )
end
# T = Themes.GitHubTheme
# str, colors = highlight_text(Pkg.dir("GLVisualize", "src", "examples", "ExampleRunner.jl"), T)
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
