using GLVisualize, Colors, FixedPointNumbers
using Base.Test

@test GLVisualize.Intensity{Float32}(Gray(N0f8(0.8))) == GLVisualize.Intensity{Float32}(Float32(N0f8(0.8)))

nothing
