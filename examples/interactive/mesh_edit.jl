using GeometryTypes, GLVisualize, GLAbstraction, Reactive, GLWindow, GLFW
using ModernGL, Colors
msh = loadasset("cat.obj")
const w = GLPlot.viewing_screen
v = vertices(msh)
f = faces(msh)
colors = RGBA{Float32}[RGBA{Float32}(rand(), rand(), rand(), 1.) for i=1:length(v)]
colored_mesh = GLNormalVertexcolorMesh(
    vertices=v, faces=f,
    color=colors
)
model = translationmatrix(Vec3f0(2, 0, 0))
cat_robj = glplot(colored_mesh, model=model).children[]
indices = decompose(Face{2, GLuint, -1}, colored_mesh)
line_robj = glplot(
    cat_robj[:vertices], :linesegment,
    indices=reinterpret(GLuint, indices),
    thickness=2.5f0, color=RGBA{Float32}(1,1,1,1),
    preferred_camera=:perspective,
    model=model
).children[]
const gpu_position = line_robj[:vertex]

point_robj = glplot(
    (Circle(Point2f0(0), 0.01f0), gpu_position),
    billboard=true,
    preferred_camera=:perspective,
    model=model
).children[]



const m2id = mouse2id(w)
# interaction
@materialize mouse_buttons_pressed, mouseposition = w.inputs
isoverpoint = const_lift(is_same_id, m2id, point_robj)

# single left mousekey pressed (while no other mouse key is pressed)
key_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
# righ
right_pressed = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_RIGHT)
# dragg while key_pressed. Drag only starts if isoverpoint is true
mousedragg = GLAbstraction.dragged(mouseposition, key_pressed, isoverpoint)
camera = w.cameras[:perspective]

# use mousedrag and mouseid + index to actually change the gpu array with the positions
function apply_drag(v0, dragg)
    if dragg == Vec2f0(0) # if drag just started. Not the best way, maybe dragged should return a tuple of (draggvalue, started)
        id, index = value(m2id)
        if id==point_robj.id && length(gpu_position) >= index
            prj_view = value(camera.projectionview)
            p0 = Point4f0(prj_view * Vec4f0(gpu_position[index], 1))
        else
            p0 = v0[3]
        end
    else
        id, index, p0 = v0
        if id==point_robj.id && length(gpu_position) >= index
            prj_view_inv = inv(value(camera.projectionview))
            area = value(camera.window_size)
            cam_res = Vec2f0(widths(area))
            dragg_clip_space = (Vec2f0(dragg)./cam_res) * p0[4] * 2
            pos_clip_space = p0 + Point4f0(dragg_clip_space, 0, 0)
            p_world_space = Point3f0(prj_view_inv * Vec4f0(pos_clip_space))
            gpu_position[index] = p_world_space
        end

    end
    return id, index, p0
end

x = preserve(foldp(apply_drag, (value(m2id)..., Point4f0(0)), mousedragg))
