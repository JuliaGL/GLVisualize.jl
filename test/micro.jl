using GLVisualize, Colors, FixedPointNumbers
using Base.Test

@test GLVisualize.Intensity{1,Float32}(Gray(N0f8(0.8))) == GLVisualize.Intensity{1,Float32}(Float32(N0f8(0.8)))

nothing
