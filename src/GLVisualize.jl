VERSION >= v"0.4.0-dev+6521" && __precompile__(true)
module GLVisualize

using GLFW
using GLWindow
using GLAbstraction
using ModernGL
using FixedSizeArrays
using GeometryTypes
using ColorTypes
using Colors
using Reactive
using Quaternions
using Compat
using FixedPointNumbers
using FileIO
using Packing
using SignedDistanceFields
import Images

typealias GLBoundingBox AABB{Float32}

import Base: merge, convert, show


shaderdir() = Pkg.dir("GLVisualize", "src", "shader")

include("FreeTypeAbstraction.jl")

include("types.jl")
include("boundingbox.jl")

include("visualize_interface.jl")
export view #push renderobject into renderlist of the default screen, or supplied screen
export visualize    # Visualize an object
export visualize_default # get the default parameter for a visualization

include("utils.jl")
export y_partition
export x_partition
export loop, bounce
export clicked, dragged_on, is_hovering
export MouseButton, MOUSE_LEFT, MOUSE_MIDDLE, MOUSE_RIGHT
export OR, AND, isnotempty

include(joinpath("display", "renderloop.jl"))


include(joinpath("texture_atlas", 	"texture_atlas.jl"))
export Sprite
export GLSprite
export SpriteStyle
export GLSpriteStyle

include(joinpath("edit", "color_chooser.jl"))
include(joinpath("edit", "numbers.jl"))
include(joinpath("edit", "line_edit.jl"))
export vizzedit # edits some value, name should be changed in the future!

include(joinpath("visualize", "text", "utils.jl"))
include(joinpath("visualize", "lines.jl"))
include(joinpath("visualize", "containers.jl"))
include(joinpath("visualize", "image_like.jl"))
include(joinpath("visualize", "mesh.jl"))
include(joinpath("visualize", "particles.jl"))
include(joinpath("visualize", "surface.jl"))
include(joinpath("visualize", "text.jl"))
include(joinpath("visualize", "videos.jl"))
include(joinpath("visualize", "volume.jl"))

include("camera.jl")
export cubecamera

Base.precompile(glscreen, ())
end # module
