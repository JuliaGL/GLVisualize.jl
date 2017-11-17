"""
Module to keep global configs
Should become customizable at some point!
"""
module Config

using Reactive, GeometryTypes, Colors, GLFW, GLWindow, GLAbstraction

# don't want to repeat the compatibility code
import GLAbstraction: N0f8

# const shortcuts = Dict(
#     "paste" => Signal([GLFW.KEY_LEFT_CONTROL, GLFW.KEY_V]),
#     "copy"  => Signal([GLFW.KEY_LEFT_CONTROL, GLFW.KEY_C]),
#     "cut"   => Signal([GLFW.KEY_LEFT_CONTROL, GLFW.KEY_X]),
#     "rotate cam xy" => Signal([MOUSE_LEFT, GLFW.KEY_LEFT_CONTROL]),
# )

"""
default returns common defaults for a certain style and datatype.
This is convenient, to quickly switch out default styles.
"""
default(::T, s::Style=Style{:default}()) where {T} = default(T, s)

function default(::Type{T}, s::Style=Style{:default}(), index=1) where T <: Colorant
    color_defaults = RGBA{Float32}[
    	RGBA{Float32}(0.0f0,0.74736935f0,1.0f0,1.0f0),
    	RGBA{Float32}(0.78, 0.01, 0.93, 1.0),
    	RGBA{Float32}(0, 0, 0, 1.0),
    	RGBA{Float32}(0.78, 0.01, 0, 1.0)
    ]
    index > length(color_defaults) && error("There are only three color defaults.")
    color_defaults[index]
end
function default(::Type{Vector{T}}, s::Style = Style{:default}()) where T <: Colorant
    map(RGBA{N0f8}, colormap("Blues", 7))
end
export default

end
