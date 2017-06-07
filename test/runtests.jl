include("micro.jl")

function is_ci()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true"
end

if is_ci()
    # need this branch for better coverage report!
    cd(Pkg.dir("GLAbstraction")) do
        run(`git fetch origin`)
        run(`git checkout master`)
    end
    include("test_static.jl")
else
    include("test_interactive.jl")
end
