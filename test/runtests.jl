include("micro.jl")

function is_ci()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true"
end

if is_ci()
    include("test_static.jl")
else
    include("test_interactive.jl")
end
