module GLParallel

using GLVisualize
using GLFW
using GLWindow
using GLAbstraction
using ModernGL
using GeometryTypes
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
    @spawnat workerid[] begin
        GLAbstraction.set_arg!(fetch(obj), key, value)
        #Reactive.post_empty()
        nothing
    end
end

function _view(main, style=:default, cam=:perspective; kw_args...)
    @spawnat workerid[] begin
        obj = GLVisualize.visualize(main, style; kw_args...)
        GLVisualize._view(obj, camera=cam)
        obj
    end
end

function is_current_open()
    remotecall_fetch(workerid[]) do
        isempty(GLVisualize.get_screens()) && return false
        isopen(GLVisualize.current_screen())
    end
end

function empty_current!()
    remotecall(workerid[]) do
        empty!(GLVisualize.current_screen())
        nothing
    end
end

global const workerid = Ref(0)

function glscreen(
        id = workers()[end];
        color = RGBA(1f0, 1f0, 1f0, 1f0)
    )
    if workerid[] == 0 || id != workers()[end]
        workerid[] = id
    end
    # start GLVisualize worker process
    @spawnat workerid[] begin
        window = GLVisualize.glscreen(color = color)
        @async GLWindow.waiting_renderloop(window)
        nothing
    end
end

end
