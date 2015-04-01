module GLVisualize

using GLWindow 
using GLAbstraction
using ModernGL
using GeometryTypes
using Reactive
using GLFW
using Images
using Quaternions
using GLText
using Compat
using Color
using FixedPointNumbers
import Mustache

const sourcedir = Pkg.dir("GLVisualize", "src")
const shaderdir = joinpath(sourcedir, "shader")



include(joinpath(     sourcedir, "utils.jl"))
include(joinpath(     sourcedir, "types.jl"))
include_all(joinpath( sourcedir, "display"))
include(joinpath(     sourcedir, "color.jl"))
include_all(joinpath( sourcedir, "share"))
include_all(joinpath( sourcedir, "edit"))
include_all(joinpath( sourcedir, "visualize"))
include(joinpath(     sourcedir, "visualize_interface.jl"))
include(joinpath(     sourcedir, "edit_interface.jl"))

export visualize    # Visualize an object
export edit         # Edit an object



# Surface Rendering
export mix      # mix colors
export SURFACE  # function that generates a Surface primitive for every datapoint, with an optional gap between the surfaces
export CIRCLE   # function that generates Circular surface primitive for every datapoint
export CUBE     # function that generates Cube primitives for every datapoint
export POINT    # function that generates Point primitives for every datapoint

end # module
