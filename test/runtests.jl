include("micro.jl")

function is_ci()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") == "true" ||
    get(ENV, "CI", "") == "true"
end

if is_ci()

    # TODO remove before final merge
    Pkg.checkout("FreeTypeAbstraction", "sd/06")
    Pkg.checkout("Packing", "sd/06")
    Pkg.checkout("GLWindow", "sd/staticarrays")
    Pkg.checkout("MeshIO", "sd/staticarrays")
    Pkg.checkout("GLAbstraction", "sd/staticarrays")
    Pkg.checkout("GeometryTypes", "sd/fixes_rebased")

    include("test_static.jl")
else
    include("test_interactive.jl")
end
