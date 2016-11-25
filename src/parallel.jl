module GLParallel

using GLVisualize
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
using FixedPointNumbers
using FileIO
using Packing
using SignedDistanceFields
using FreeType


# Parallel helper function to launch our glvisualize operations on the process,
# on which we run GLVisualize
# I will move these functions to GLVisualize once this is tested better!
function set_arg!(obj, key, value)
    @spawnat workerid begin
        GLAbstraction.set_arg!(fetch(obj), key, value)
        nothing
    end
end

function _view(main, style=:default, cam=:perspective; kw_args...)
    @spawnat workerid begin
        obj = GLVisualize.visualize(main, style; kw_args...)
        GLVisualize._view(obj, camera=cam)
        obj
    end
end

function is_current_open()
    remotecall_fetch(workerid) do
        isempty(GLVisualize.get_screens()) && return false
        isopen(GLVisualize.current_screen())
    end
end

function empty_current!()
    remotecall(workerid) do
        empty!(GLVisualize.current_screen())
        nothing
    end
end

function glscreen(
        id = workers()[end];
        color = RGBA(1f0, 1f0, 1f0, 1f0)
    )
    global const workerid = id
    # start GLVisualize worker process
    @spawnat workerid begin
        window = GLVisualize.glscreen(color = color)
        @async GLWindow.waiting_renderloop(window)
        nothing
    end
end

end
