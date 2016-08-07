using GLVisualize, GLAbstraction, GeometryTypes, Colors, Reactive
import GLVisualize: Visualization, default

function Visualization(x, s; kw_args...)
    Visualization(x, s, Dict{Symbol, Any}(kw_args))
end
function Visualization{T}(position::T, s::style"lines", data::Dict)
    pv = value(position)
    @gen_defaults! data begin
        dims::Vec{2, Int} = ndims(pv) == 1 ? (length(pv), 1) : size(pv)
        dotted = false
        position = position
        color = default(RGBA, s, 1)
        stroke_color = default(RGBA, s, 2)
        thickness = 1.0
        shape = RECTANGLE
        boundingbox = AABB{Float32}(position)
        indices = const_lift(length, position)
    end
    Visualization{T, :lines}(
        main=position, parameters=data, boundingbox=boundingbox
    )
end

x = Visualization(rand(Point3f0, 100), style"lines"())
using GLWindow
name = "lolz"
screen = Screen(name)
GLWindow.add_complex_signals!(screen) #add the drag events and such
GLWindow.add_oit_fxaa_postprocessing!(screen) # add postprocessing
