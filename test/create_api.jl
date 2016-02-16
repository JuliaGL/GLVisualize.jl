#=
Used to write out all function documentations as a markdown file
=#
using GLVisualize

metadict = Docs.meta(GLVisualize)

function write_docs(a, b, io)
    # ignore unimplemented types
    nothing
end
function write_docs(f::Function, fd::Docs.FuncDoc, io)
    println(io, "`", f, "`")
    for (k,v) in fd.meta
        println(io, "args: `(", join(map(x->"::$x", k.types), ", "), ")`")
        writemime(io, MIME"text/markdown"(), v)
        println(io)
    end
    println(io, "\n") # two newlines
end


function write_docs{T}(::Type{T}, td::Docs.TypeDoc, io)
    println(io, "`", T, "`")
    for (k,v) in td.meta
        println(io, "args: `(", join(map(x->"::$x", k.types), ", "), ")`")
        writemime(io, MIME"text/markdown"(), v)
        println(io)
    end
    println(io, "\n") # two newlines
end
open("api.md", "w") do io
    for (k, v) in metadict
        write_docs(k, v, io)
    end
end
