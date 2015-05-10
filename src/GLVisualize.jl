module GLVisualize

using GLWindow 
using GLAbstraction
using ModernGL
using FixedSizeArrays
using GeometryTypes
using ColorTypes
using Reactive
using GLFW
using Quaternions
using Compat
using FixedPointNumbers
using ImageIO
using FileIO
using MeshIO
using Meshes
using AbstractGPUArray
import Mustache
import Base: merge, convert, show



include("meshutil.jl")

const sourcedir = Pkg.dir("GLVisualize", "src")
const shaderdir = joinpath(sourcedir, "shader")


include(joinpath(     sourcedir, "utils.jl"))
include(joinpath(     sourcedir, "boundingbox.jl"))

export loop
export bounce

include(joinpath(     sourcedir, "types.jl"))
include_all(joinpath( sourcedir, "display"))

include(joinpath(     sourcedir, "visualize_interface.jl"))

include(joinpath(     sourcedir, "color.jl"))
include_all(joinpath( sourcedir, "share"))
include_all(joinpath( sourcedir, "edit"))
include_all(joinpath( sourcedir, "visualize"))
include(joinpath(     sourcedir, "edit_interface.jl"))

export renderloop 
export visualize    # Visualize an object
export edit         # Edit an object

export RGBAU8       # typealias for RGBA ufixed 8 value
export rgba         # function for creating a rgba Float32 color
export rgbaU8       # function for creating a rgba Ufixed8 color

export tohsva       # Convert to HSVA
export torgba       # Converts to RGBA

# Surface Rendering
export mix      # mix colors
export SURFACE  # function that generates a Surface primitive for every datapoint, with an optional gap between the surfaces
export CIRCLE   # function that generates Circular surface primitive for every datapoint
export CUBE     # function that generates Cube primitives for every datapoint
export POINT    # function that generates Point primitives for every datapoint


end # module
