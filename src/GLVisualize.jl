__precompile__(true)
module GLVisualize

using GLFW
using GLWindow
using GLAbstraction
using ModernGL
using StaticArrays
using GeometryTypes
using Colors
using Reactive
using Quaternions
using FixedPointNumbers
using FileIO
using Packing
using SignedDistanceFields
using FreeType
import IterTools
using Base.Markdown
using FreeTypeAbstraction

import ColorVectorSpace
import GLAbstraction: N0f8
export N0f8 # reexport for examples/tests

import Base: merge, convert, show
using Base.Iterators: Repeated, repeated

import AxisArrays, ImageAxes, Images
using IndirectArrays
const HasAxesArray{T, N} = Union{AxisArrays.AxisArray{T, N}, Images.ImageMetadata.ImageMetaAxis{T, N}}
const AxisMatrix{T} = HasAxesArray{T, 2}


const GLBoundingBox = AABB{Float32}

export renderloop

"""
Replacement of Pkg.dir("GLVisualize") --> GLVisualize.dir,
returning the correct path
"""
dir(dirs...) = joinpath(dirname(@__FILE__), "..", dirs...)

"""
returns path relative to the assets folder
"""
assetpath(folders...) = dir("assets", folders...)

"""
Loads a file from the asset folder
"""
function loadasset(folders...; kw_args...)
    path = assetpath(folders...)
    isfile(path) || isdir(path) || error("Could not locate file at $path")
    load(path; kw_args...)
end

export assetpath, loadasset


include("StructsOfArrays.jl")
using .StructsOfArrays

include("types.jl")
export CIRCLE, RECTANGLE, ROUNDED_RECTANGLE, DISTANCEFIELD, TRIANGLE

include("config.jl")
using .Config
import .Config: default

include("boundingbox.jl")

include("visualize_interface.jl")
export _view #push renderobject into renderlist of the default screen, or supplied screen
export visualize # Visualize an object
export visualize_default # get the default parameter for a visualization

include("utils.jl")
export y_partition, y_partition_abs
export x_partition, x_partition_abs
export loop, bounce
export clicked, dragged_on, is_hovering
export OR, AND, isnotempty
export color_lookup

include("renderloop.jl")


include("texture_atlas.jl")

include(joinpath("gui", "color_chooser.jl"))
include(joinpath("gui", "numbers.jl"))
include(joinpath("gui", "line_edit.jl"))
include(joinpath("gui", "buttons.jl"))
include(joinpath("gui", "options.jl"))
include(joinpath("gui", "container.jl"))

export widget # edits some value, name should be changed in the future!

include(joinpath("visualize", "lines.jl"))
include(joinpath("visualize", "containers.jl"))
include(joinpath("visualize", "image_like.jl"))
include(joinpath("visualize", "mesh.jl"))
include(joinpath("visualize", "particles.jl"))
include(joinpath("visualize", "surface.jl"))
include(joinpath("visualize", "text.jl"))

include("camera.jl")
export cubecamera

# Compose/Gadfly  backend has a weird missplaced expression error right now.
# Lets disable it for now
#include("compose_backend.jl")

include("videotool.jl")
export create_video

include("documentation.jl")
export get_docs

#include("../precompile/glv_userimg.jl")

include("parallel.jl")

end # module
