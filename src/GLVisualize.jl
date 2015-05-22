module GLVisualize

using GLFW
using GLWindow 
using GLAbstraction
using ModernGL
using FixedSizeArrays
using GeometryTypes
using ColorTypes
using Reactive
using Quaternions
using Compat
using FixedPointNumbers
using ImageIO
using FileIO
using MeshIO
using Meshes
using AbstractGPUArray
using Packing
using Cairo

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
include(joinpath("texture_atlas", "texture_atlas.jl"))

include(joinpath(     sourcedir, "color.jl"))
include_all(joinpath( sourcedir, "share"))
include_all(joinpath( sourcedir, "edit"))
include_all(joinpath( sourcedir, "visualize"))

include(joinpath(     sourcedir, "edit_interface.jl"))

export renderloop   # starts the renderloop
export visualize    # Visualize an object
export edit         # Edit an object



end # module
