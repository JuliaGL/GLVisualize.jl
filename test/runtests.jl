include("micro.jl")

function is_ci()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true"
end

if is_ci()
    println("is CI")
    cd(Pkg.dir("GLAbstraction")) do
        run(`git checkout master`)
    end
    cd(Pkg.dir("GLWindow")) do
        run(`git checkout master`)
    end
    include("test_static.jl")
else
    include("test_interactive.jl")
end
