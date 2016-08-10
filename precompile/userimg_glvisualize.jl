using SnoopCompile

SnoopCompile.@snoop "glp_compiles.csv" begin
    using GLPlot;GLPlot.init()
    using Colors, GeometryTypes
    glplot(rand(Float32, 32,32))
    glplot(rand(Float32, 32,32), :surface)
    glplot(rand(Point3f0,32))
    glplot(rand(Point3f0,32), :lines)
    glplot(rand(Point2f0,32), :lines)
    glplot(rand(Point2f0,32))
    glplot(RGBA{Float32}[RGBA{Float32}(rand(), rand(), rand(), rand()) for i=1:512, j=1:512])
    while isopen(GLPlot.viewing_screen)
        yield()
    end
end

using GLPlot
data = SnoopCompile.read("glp_compiles.csv")
blacklist = ["MIME"]
pc = SnoopCompile.format_userimg(data[end:-1:1,2], blacklist=blacklist)
SnoopCompile.write(Pkg.dir("GLPlot", "src", "glp_userimg.jl"), pc)


#=
real	0m13.712s
user	0m15.872s
sys	0m0.176s
=#
include(joinpath(JULIA_HOME, "..", "..", "contrib", "build_sysimg.jl"))
userimg_path = Pkg.dir("GLVisualize", "precompile", "userimg.jl")
#build_sysimg(default_sysimg_path(), "native", nothing; force=true)

build_sysimg(default_sysimg_path(), "native", userimg_path; force=true)
