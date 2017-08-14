
pretty_print(x::Signal) = string(value(x))
pretty_print(x::Vector) = string("[", first(x), "...", last(x), "]")
pretty_print(x::Matrix{T}) where {T} = string("Matrix{", T, "}")
pretty_print(x::DataType) = string(x.name.name)
pretty_print(x) = string(x)

print_type(x::Function) = string(x.env.name)
print_type(x::Symbol) = string(":", x)
function print_type(x::Type{T}) where T<:Tuple
    "($(join(map(print_type, x.parameters), ", ")))"
end
function print_type(x::TypeVar)
    string(x.name)
end
print_type(x::TypeName) = print_type(x.name)
print_type(x::UnionAll) = sprint(io-> show(io, x))
print_type(x) = print_type(x.name)
function print_type(x::Union)
    "Union{$(join(map(print_type, Base.uniontypes(x)), " "))}"
end


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
    :shading => "Accepts true or false. When true, uses blinn phong shading, otherwise flat"
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

function get_doc(dict, sig)
    for (k, v) in dict
        k == sig && return v.text[1]
    end
    ""
end
_tuple(x) = (x,)
_tuple(x::Core.SimpleVector) = tuple(x...)
_tuple(x::Tuple) = x
_tuple(x::Type{T}) where {T<:Tuple} = tuple(x.parameters...)

function all_docs(io = STDOUT)
    method_table = methods(GLVisualize._default)
    metadict = Docs.meta(GLVisualize)
    default_docs = metadict[Base.Docs.Binding(GLVisualize, :_default)].docs

    for method in method_table
        println(io, method)
        println(io)
        # sig_types = method.sig
        # if isa(sig_types, UnionAll)
        #     sig_types = Base.unwrap_unionall(sig_types)
        # end
        # sig = (sig_types.parameters[2:end]...,)
        # world = typemax(UInt)
        # x = first(Base._methods(GLVisualize._default, Tuple{sig...}, -1, world))
        # tvars = _tuple(x)[2:end]
        # sparam = if !isempty(tvars)
        #     string("{", join(map(x-> string(x), tvars), ", "), "}")
        # else
        #     ""
        # end
        # docstr = get_doc(default_docs, Tuple{sig...})
        # arg1 = print_type(sig[1])
        # arg2 = if isa(sig[2],  UnionAll) #
        #     ""
        # else
        #     string(", :", sig[2].parameters[1])
        # end
        # print(io, docstr)
        # println(io, "visualize", sparam, "(", arg1, arg2, ")")
        # println(io)
    end

end
