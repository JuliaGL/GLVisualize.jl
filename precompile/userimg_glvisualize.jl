using SnoopCompile

SnoopCompile.@snoop "glv_compiles.csv" begin
    include("test/ExampleRunner.jl")
    using ExampleRunner
    config = ExampleRunner.RunnerConfig(
        number_of_frames = 2,
        interactive_time = 0.01,
        record=false,
        resolution = (100, 100)
    )
    ExampleRunner.run(config)
end

using GLVisualize

str = open("glv_compiles.csv") do io
    str = readstring(io)
    x = replace(str, r"[0-9]+\t\"<toplevel thunk> [\s\S]+?\)::Any\]\"\n", "")
end
open("glv_compiles.csv", "w") do io
    seekstart(io)
    print(io, str)
end
data = SnoopCompile.read("glv_compiles.csv")
blacklist = [
    "MIME", "Base", "Core",
    "ExampleRunner", "ImageMagick", "Contour", "MeshIO"
]
pc = SnoopCompile.format_userimg(data[end:-1:1,2], blacklist=blacklist)
SnoopCompile.write(GLVisualize.dir("precompile", "glv_userimg.jl"), pc)

#=
real	0m13.712s
user	0m15.872s
sys	0m0.176s
=#

include(joinpath(JULIA_HOME, "..", "..", "contrib", "build_sysimg.jl"))
build_sysimg(default_sysimg_path(), "native", nothing; force=true)

userimg_path = GLVisualize.dir("precompile", "userimg.jl")

build_sysimg(default_sysimg_path(), "native", userimg_path; force=true)
