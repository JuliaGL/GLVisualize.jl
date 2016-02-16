function file2doc(name, source_path, doc_md_io, screencapture_file)
    if screencapture_file == nothing
        preview = "" # aww, no screencapture :(
    elseif endswith(screencapture_file, ".webm")
        preview = """<video  width="600" autoplay loop>
          <source src="../../media/$(screencapture_file)">
              Your browser does not support the video tag.
        </video>
        """
    else # should be an image
        preview = "![$(name)](../../media/$(screencapture_file))"
    end

    # declutter the source a bit
    source_code = open(source_path) do io
        sprint() do str_io
            needs_end = false
            for line in readlines(io)
                line = chomp(line)
                if startswith(line, "if !isdefined(:runtests)")
                    needs_end = true
                    continue
                end
                if startswith(line, "end") && needs_end
                    needs_end = false
                    continue
                end
                if (
                        startswith(line, "const record_interactive = true") ||
                        startswith(line, "const static_example = true")
                    )
                    continue
                end
                if needs_end # we are in a !isdefined(:runtests) block
                    # we should remove the tabs
                    if beginswith(line, " "^4)
                        line = line[4:end]
                    elseif beginswith(line, "\t")
                        line = line[2:end]
                    end
                end
                println(str_io, line)
            end

        end
    end
    print(doc_md_io, 
"""
# $name

$(preview)

```Julia
$(source_code)
```

"""
    )
end
function remove_root(root, path)
    rootsplit = split(root, Base.Filesystem.path_separator)
    pathsplit = split(path, Base.Filesystem.path_separator)

    path = joinpath(pathsplit[length(rootsplit):end]...)
    path
end
function file2doc(sourcepath, doc_md_io)
    filename = basename(sourcepath)[1:end-3] # remove .jl
    headlines = split(filename, "_")
    name = join(map(x->ucfirst(x), headlines), " ")
    # get matching screen record
    println("filename ", filename)
    screencapture = filter(readdir(screencapture_root)) do file
        fname, ext = splitext(file)
        fname == filename
    end
    if isempty(screencapture)
        #no record found for filename, so it's nothing
        screencapture = nothing
    elseif length(screencapture) == 1
        screencapture = screencapture[1]
    elseif length(screencapture) > 1
       warn("found duplicate screen recordings for: $filename")
    end
    println("screencapture ", screencapture)
    file2doc(name, sourcepath, doc_md_io, screencapture)
end

const doc_root = "C:\\Users\\Sim\\GLVisualize\\docs"
const screencapture_root = "C:\\Users\\Sim\\GLVisualize\\docs\\media"
const source_root = Pkg.dir("GLVisualize", "examples")

function make_docs(path::AbstractString)
    println(path)
    if isdir(path) # we should be on the level of jl files. eg. in dir particles with all particle examples
        name = basename(path)
        println("name ", name)
        # for one folder we only create one md, because mcdocs doesn't allow to deep hierarchies
        dir_level = remove_root(source_root, path)
        dir_level, _ = splitdir(dir_level) # remove last folder
        doc = joinpath(doc_root, dir_level, "$(name).md")
        open(doc, "w") do io
            for file in readdir(path) # read all files and concat the docs for that one
                file2doc(joinpath(path, file), io)
            end
        end
    elseif isfile(path) && endswith(path, ".jl")
        println("whaaat???")
    end
    nothing # ignore other cases
end
function make_docs(directories::Vector)
    for dir in directories
        println("dir ", dir)
        make_docs(joinpath(source_root, dir))
    end
end
function make_docs(directories::Vector, io)
    for file in directories
        file2doc(file, io)
    end
end

make_docs(readdir(source_root))