
pretty_print(x::Signal) = string(value(x))
pretty_print(x::Vector) = string("[", first(x), "...", last(x), "]")
pretty_print{T}(x::Matrix{T}) = string("Matrix{", T, "}")
pretty_print(x::DataType) = string(x.name.name)
pretty_print(x) = string(x)

s_length(x::Symbol) = length(string(x))

const default_kwargs_docs = Dict(
    :position => "must be `Vector{Point}` or `Grid` or `nothing`",
    :position_x => "must be `Vector{Float}` or `Float` or `nothing`",
    :position_y => "must be `Vector{Float}` or `Float` or `nothing`",
    :position_z => "must be `Vector{Float}` or `Float` or `nothing`",
    
    :scale => "must be `Vector{Vec}` or `Vec`",
    :scale_x => "must be `Vector{Float}` or `Float` or `nothing`",
    :scale_y => "must be `Vector{Float}` or `Float` or `nothing`",
    :scale_z => "must be `Vector{Float}` or `Float` or `nothing`",
    :color => "Must be a Colorant",
    

    :model => "Must be`Mat4f0`. Scales, rotates and positions the object",
    :preferred_camera => "Preferred camera",
    :light => "Light to illuminate the model",
)
function get_docs(arg1, style=:default)
    s = Style{style}()
    data = _default(arg1, s, Dict{Symbol, Any}(
        :shader => nothing # don't let _default create a shader, a window is necessary for that
    ))
    doc = get(data, :doc_string, Dict())
    targets = get(data, :gl_convert_targets, Dict())
    # we don't want to have these in the docs, so remove them
    delete!(data, :doc_string) 
    delete!(data, :gl_convert_targets)

    maxlen = maximum(map(s_length, keys(data)))
    io = IOBuffer()
    for (k, value) in data
        spaces = maxlen - s_length(k)
        docstring = get(doc, k, get(default_kwargs_docs, k, ""))
        if docstring != ""
            docstring = docstring
        end
        t = string(get(targets, k, ""))
        if t != ""
            t = "can be gpu type: "*pretty_print(t)
        end
        println(io, " ", k, " "^spaces, " = ", pretty_print(value))
        println(io, docstring)
        println(io, t)
        println(io)
        println(io, "---")
        println(io)
    end
    seekstart(io)
    Markdown.parse(io)
end