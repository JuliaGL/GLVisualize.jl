using GeometryTypes, GLVisualize, GLAbstraction, Reactive
w = glscreen()
n = 50
a = rand(Point2f0, 50)*1000f0
points = visualize((Circle(Point2f0(0), 15f0), a))
const point_robj = points.children[] # temporary way of getting the render object. Shouldn't stay like this
 # best way to get the gpu object. One could also start by creating a gpu array oneself.
 # this is a bit tricky, since not there are three different types.
 # for points and lines you need a GLBuffer. e.g gpu_position = GLBuffer(rand(Point2f0, 50)*1000f0)
const gpu_position = point_robj[:position]
# now the lines and points share the same gpu object
# for linesegments, you can pass indices, which needs to be of some 32bit int type
lines  = visualize(gpu_position, :linesegment, indices=rand(Cuint(1):Cuint(n), 100))

# current tuple of renderobject id and index into the gpu array
const m2id = GLWindow.mouse2id(w)
isoverpoint = const_lift(is_same_id, m2id, point_robj)

# inputs are a dict, materialize gets the keys out of it (equivalent to mouseposition = w.inputs[:mouseposition])
@materialize mouse_buttons_pressed, mouseposition = w.inputs

# single left mousekey pressed (while no other mouse key is pressed)
key_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
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
# view it!
view(lines)
view(points)

renderloop(w)
