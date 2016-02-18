#=
Used to write out all function documentations as a markdown file
=#
using GLVisualize

metadict = Docs.meta(GLVisualize)

function write_docs(a, b, io)
    # ignore unimplemented types
    nothing
end

print_type(x::Function) = string(x.env.name)
print_type(x::Symbol) = string(x)
print_type(x::TypeName) = print_type(x.name)
print_type(x) = print_type(x.name)
print_type(x::Union) = "Union{$(join(map(print_type, x.types), " "))}"

function write_docs(fun::Union{Function, DataType}, fd::Union{Docs.TypeDoc, Docs.FuncDoc}, io)
    println(io, "## `", print_type(fun), "`")
    for (k,v) in fd.meta
        println(io, "args: `(", join(map(x->"::$(print_type(x))", k.types), ", "), ")`")
        println(io)
        writemime(io, MIME"text/markdown"(), v)
        println(io)
        println(io, "---")
        println(io)
    end
    println(io, "\n") # two newlines
end


const doc_root = "C:\\Users\\Sim\\GLVisualize\\docs"

open(joinpath(doc_root, "api.md"), "w") do io
    for (k, v) in metadict
        write_docs(k, v, io)
    end
end
