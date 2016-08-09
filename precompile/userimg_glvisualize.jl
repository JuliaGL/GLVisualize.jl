using SnoopCompile

SnoopCompile.@snoop "glv_compiles.csv" begin
    include(Pkg.dir("GLVisualize", "test","runtests.jl"))
end

using GLVisualize
data = SnoopCompile.read("glv_compiles.csv")
blacklist = ["MIME"]
pc = SnoopCompile.format_userimg(data[end:-1:1,2], blacklist=blacklist)
SnoopCompile.write(Pkg.dir("GLVisualize", "src", "glv_userimg.jl"), pc)


#=
real	0m13.712s
user	0m15.872s
sys	0m0.176s
=#
include(joinpath(JULIA_HOME, "..", "..", "contrib", "build_sysimg.jl"))
userimg_path = Pkg.dir("GLVisualize", "precompile", "userimg.jl")
build_sysimg(default_sysimg_path(), "native", nothing; force=true)

build_sysimg(default_sysimg_path(), "native", userimg_path; force=true)
