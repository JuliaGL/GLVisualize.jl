using GeometryTypes, GLVisualize, GLAbstraction, Reactive, GLWindow, GLFW

if !isdefined(:runtests)
window = glscreen()
end
const record_interactive = true

n = 50
n_connections = 100
a = rand(Point2f0, n)*1000f0
indices = Signal(rand(1:n, n_connections))
# for the points, we only need unique indices!
unique_indices = map(unique, indices)
points = visualize((Circle(Point2f0(0), 15f0), a), indices=unique_indices)

const point_robj = points.children[] # temporary way of getting the render object. Shouldn't stay like this
 # best way to get the gpu object. One could also start by creating a gpu array oneself.
 # this is a bit tricky, since not there are three different types.
 # for points and lines you need a GLBuffer. e.g gpu_position = GLBuffer(rand(Point2f0, 50)*1000f0)
const gpu_position = point_robj[:position]
# GPUVector adds functionality like push! and splice!
# now the lines and points share the same gpu object
# for linesegments, you can pass indices, which needs to be of some 32bit int type
lines  = visualize(gpu_position, :linesegment, indices=indices)

# current tuple of renderobject id and index into the gpu array
const m2id = GLWindow.mouse2id(window)
isoverpoint = const_lift(is_same_id, m2id, point_robj)

# inputs are a dict, materialize gets the keys out of it (equivalent to mouseposition = window.inputs[:mouseposition])
@materialize mouse_buttons_pressed, mouseposition = window.inputs

# single left mousekey pressed (while no other mouse key is pressed)
key_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
# righ
right_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_RIGHT)
# dragg while key_pressed. Drag only starts if isoverpoint is true
mousedragg  = GLAbstraction.dragged(mouseposition, key_pressed, isoverpoint)

# use mousedrag and mouseid + index to actually change the gpu array with the positions
preserve(foldp((value(m2id)..., Point2f0(0)), mousedragg) do v0, dragg
    if dragg == Vec2f0(0) # if drag just started. Not the best way, maybe dragged should return a tuple of (draggvalue, started)
        id, index = value(m2id)
        if id==point_robj.id && length(gpu_position) >= index
            p0 = gpu_position[index]
        else
            p0 = v0[3]
        end
    else
        id, index, p0 = v0
        if id==point_robj.id && length(gpu_position) >= index
            gpu_position[index] = Point2f0(p0) + Point2f0(dragg)
        end

    end
    return id, index, p0
end)
# On right click remove nodes!
preserve(map(right_pressed) do rp
    id, index = value(m2id)
    if rp && id==point_robj.id && length(gpu_position) >= index
        new_indices = Int[]
        indice_val = value(indices)
        for i=1:2:length(indice_val) #filter out indices
            a, b = indice_val[i], indice_val[i+1]
            if a != index && b != index
                push!(new_indices, a, b)
            end
        end
        push!(indices, new_indices) # update indices!
    end
end)
# view it!
view(lines, window, camera=:fixed_pixel)
view(points, window, camera=:fixed_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
