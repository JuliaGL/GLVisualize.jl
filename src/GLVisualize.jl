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
using FreeTypeAbstraction
using VideoIO



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


include(joinpath(     sourcedir, 	"visualize_interface.jl"))
export view
export visualize    # Visualize an object
export visualize_default # get the default parameter for a visualization

include(joinpath("texture_atlas", 	"texture_atlas.jl"))
export Sprite
export GLSprite
export SpriteStyle
export GLSpriteStyle

include(joinpath(     sourcedir, "color.jl"))
include_all(joinpath( sourcedir, "share"))
include_all(joinpath( sourcedir, "edit"))
include_all(joinpath( sourcedir, "visualize"))
include(joinpath( sourcedir, "visualize", "text", "utils.jl"))

include(joinpath(     sourcedir, "edit_interface.jl"))

export renderloop   # starts the renderloop
export vizzedit         # Edit an object


function init(window_name="GLVisualize", resolution=(1000,1000))
	
end

end # module
