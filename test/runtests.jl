for pkg in ("GLAbstraction", "GeometryTypes", "GLWindow")
    Pkg.checkout(pkg, "sd/staticarrays")
end
Pkg.checkout("ModernGL", "sd/v06")
Pkg.checkout("StaticArrays", "sd/fixedsizearrays")
Pkg.clone("https://github.com/JuliaGraphics/FreeTypeAbstraction.jl.git")

include("micro.jl")

function isheadless()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true"
end

if isheadless()
    # need this branch for better coverage report!
    cd(Pkg.dir("GLAbstraction")) do
        run(`git fetch origin`)
        run(`git checkout master`)
    end
    include("test_static.jl")
else
    include("test_interactive.jl")
end
