include("micro.jl")

function isheadless()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true"
end

if isheadless()
    # need this branch for better coverage report!
    include("test_static.jl")
else
    include("test_interactive.jl")
end
