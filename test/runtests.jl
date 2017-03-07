function isheadless()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true"
end

if isheadless()
    # need this branch right now!
    cd(Pkg.dir("GLFW")) do
        run(`git fetch origin`)
        run(`git checkout sd/warn`)
    end
    include("test_static.jl")
else
    include("test_interactive.jl")
end
