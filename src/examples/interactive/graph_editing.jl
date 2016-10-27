using GeometryTypes, GLVisualize, GLAbstraction, Reactive, GLWindow, GLFW, Colors

const description = """
You can drag the edges of this graph,
or remove them with a right click.
Camera is fixed in this example.
"""

if !isdefined(:runtests)
    window = glscreen()
end
window.color = RGBA(0.04f0, 0.02f0, 0.05f0, 1f0)

const record_interactive = true

n = 200
n_connections = 200
w, h = widths(window)
a = map(x->x.*Point2f0(w, h), rand(Point2f0, n))
indices = Signal(rand(1:n, n_connections))
# for the points, we only need unique indices!
unique_indices = map(unique, indices)
scales = map(Vec2f0, rand(5f0:15f0, n))
colors = zeros(RGBA{Float32}, length(a))

# when scale and position is given, its enough to pass the Circle type instead of
# a concrete instance
points = visualize(
    (Circle, a),
    indices=unique_indices,
    scale=scales, offset=map(x-> -x./2f0, scales),
    color=RGBA(1f0,1f0,1f0,1f0),
    stroke_width=3f0, stroke_color=RGBA(1f0,1f0,1f0,0.4f0),
    glow_width=4f0, glow_color=colors
)

const point_robj = points.children[] # temporary way of getting the render object. Shouldn't stay like this
 # best way to get the gpu object. One could also start by creating a gpu array oneself.
 # this is a bit tricky, since not there are three different types.
 # for points and lines you need a GLBuffer. e.g gpu_position = GLBuffer(rand(Point2f0, 50)*1000f0)
const gpu_position = point_robj[:position]
const gpu_scales = point_robj[:scale]
const gpu_colors = point_robj[:glow_color]
const gpu_offset = point_robj[:offset]

# GPUVector adds functionality like push! and splice!
# now the lines and points share the same gpu object
# for linesegments, you can pass indices, which needs to be of some 32bit int type
cmap = map(RGBA{Float32}, colormap("Blues", 50))
lines = visualize(
    gpu_position, :linesegment,
    indices=indices, color=cmap[rand(1:50, n)], # sample random colors from gradient
    thickness=0.5f0
)

# current tuple of renderobject id and index into the gpu array
const m2id = GLWindow.mouse2id(window)
isoverpoint = const_lift(is_same_id, m2id, point_robj)
v0 = (0, scales, colors)
time = bounce(linspace(0f0, 1f0, 20)) # bounces between 0 - 1, for the animation
preserve(foldp(v0, isoverpoint, time) do v0, overpoint, t
    index0, scale0, color0 = v0
    if overpoint
        id, index = value(m2id)
        if id==point_robj.id && length(a) >= index
            new_colors = zeros(RGBA{Float32}, length(a))
            gpu_colors[index] = RGBA{Float32}(0.95, 0.56, t, 0.7)
            newscale = scale0[index] + t*7f0
            gpu_scales[index] = newscale
            gpu_offset[index] = -newscale./2f0
            return index, scale0, color0
        end
    else
        if index0 > 0
            gpu_colors[index0] = color0[index0]
            gpu_scales[index0] = scale0[index0]
            gpu_offset[index0] = -scale0[index0]./2f0
        end
    end
    return v0
end)

# inputs are a dict, materialize gets the keys out of it (equivalent to mouseposition = window.inputs[:mouseposition])
@materialize mouse_buttons_pressed, mouseposition = window.inputs

# single left mousekey pressed (while no other mouse key is pressed)
key_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
# righ
right_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_RIGHT)
# dragg while key_pressed. Drag only starts if isoverpoint is true
mousedragg = GLAbstraction.dragged(mouseposition, key_pressed, isoverpoint)

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
s = map(right_pressed) do rp
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
end
preserve(s)
# _view it!
_view(lines, window, camera=:fixed_pixel)
_view(points, window, camera=:fixed_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
