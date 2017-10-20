function cubeside_const_lift(_, id, mousehover)
    h_id, h_index = value(mousehover)
    if h_id == id && h_index >= 1 && h_index <= 6
        side =  CubeSides(mousehover.value[2]-1)
        side == TOP     && return Vec3f0(0,0,1)
        side == BOTTOM  && return Vec3f0(0,0,-1)
        side == FRONT   && return Vec3f0(0,1,0)
        side == BACK    && return Vec3f0(0,-1,0)
        side == LEFT    && return Vec3f0(1,0,0)
        side == RIGHT   && return Vec3f0(-1,0,0)
    end
    Vec3f0(1)
end
import Base: +
Base.clamp(x::T) where {T} = clamp(x, T(0),T(1))
+(a::RGBA{T}, b::Number) where {T} = RGBA{T}(clamp(comp1(a)+b), clamp(comp2(a)+b), clamp(comp3(a)+b), clamp(alpha(a)+b))

function cubeside_color(id, mousehover, startcolors, colortex)
    index = mousehover[2]
    update!(colortex, startcolors)
    if mousehover[1] == id
        (index >= 1 && index <= 6) && (colortex[index] = [startcolors[index] + 0.5])
    end
    nothing
end
function colored_cube()
    xdir    = Vec3f0(1f0,0f0,0f0)
    ydir    = Vec3f0(0f0,1f0,0f0)
    zdir    = Vec3f0(0f0,0f0,1f0)
    origin  = Vec3f0(-0.5)
    const quads = [
        (Quad(origin + zdir,   xdir, ydir), RGBA(1.0f0,0f0,0f0,1f0)), # Top
        (Quad(origin,          ydir, xdir), RGBA(0.5f0,0f0,0f0,1f0)), # Bottom
        (Quad(origin + ydir,   zdir, xdir), RGBA(0f0,1.0f0,0f0,1f0)), #Front
        (Quad(origin,          xdir, zdir), RGBA(0f0,0.5f0,0f0,1f0)), # Back
        (Quad(origin + xdir,   ydir, zdir), RGBA(0f0,0f0,1.0f0,1f0)), # Right
        (Quad(origin,          zdir, ydir), RGBA(0f0,0f0,0.5f0,1f0)), # Left
    ]
    cube_steering = merge(map(GLNormalMesh, quads))
end

Base.middle(r::SimpleRectangle{T}) where {T} = Point{2, T}(r.x+(r.w/T(2)), r.y+(r.mousehover/T(2)))


function get_rotation(m)
    idx = Vec3(1, 2, 3)
    xs = norm(m[1, idx])
    ys = norm(m[2, idx])
    zs = norm(m[3, idx])
    Mat4f0(
        m[1,1]/xs, m[1,2]/xs, m[1,3]/xs, 0,
        m[2,1]/ys, m[2,2]/ys, m[2,3]/ys, 0,
        m[3,1]/zs, m[3,2]/zs, m[3,3]/zs, 0,
        0     , 0     , 0     , 1,
    )
end

"""
Creates a camera which is steered by a cube for `window`.
"""
function cubecamera(
        window, projectiontype=Signal(GLAbstraction.PERSPECTIVE);
        cube_area   = Signal(SimpleRectangle(0,0,150,150)),
        eyeposition = Vec3f0(2),
        lookatv     = Vec3f0(0),
        trans       = Signal(Vec3f0(0)),
        theta       = Signal(Vec3f0(0))
    )
    T = Float32
    @materialize mouse_buttons_pressed, mouseposition, buttons_pressed = window.inputs
    dd = doubleclick(mouse_buttons_pressed, 0.3)
    mousehover = GLWindow.mouse2id(window)
    id = Signal(3)
    should_reset = filter(false, dd) do _
        x = value(mousehover).id == value(id)
    end
    cube_steering = colored_cube()
    new_eyeposition = preserve(const_lift(cubeside_const_lift,
        should_reset, id,
        Signal(mousehover)
    ))

    left_ctrl = Set([GLFW.KEY_LEFT_CONTROL])
    use_cam = map(buttons_pressed, window.inputs[:mouseinside]) do b, mi
        b == left_ctrl && mi
    end
    theta, trans = default_camera_control(
        window.inputs, Signal(0.02f0), Signal(1f0),
        use_cam
    )
    fov, upvector = map(Signal, (43f0, Vec3f0(0,0,1)))
    lookatvec, eyeposition =  Signal(lookatv), Signal(eyeposition)
    far = map(eyeposition, lookatvec) do a,b
        max(norm(b-a) * 5f0, 100f0)
    end
    near = map(eyeposition, lookatvec) do a,b
        norm(b-a) * 0.007f0
    end
    main_cam = PerspectiveCamera(
        theta ,trans, lookatvec, eyeposition, upvector,
        window.area, fov, near, far,
        projectiontype
    )
    preserve(map(new_eyeposition) do neweye_dir
        eypos, lookv = value(eyeposition), value(lookatvec)
        oldlength = norm(eypos - lookv)
        push!(eyeposition, lookv+neweye_dir*oldlength)
        for i=1:3
            unitvec = unit(Vec3f0, i)
            if dot(neweye_dir, unitvec) == 0f0 # find an orthogonal vector
                push!(upvector, unitvec)
            end
        end
    end)
    window.cameras[:perspective] = main_cam

    viewmatrix = map(main_cam.view) do m
        inv(get_rotation(m))
    end

    robj = visualize(cube_steering, model=viewmatrix)

    start_colors = cube_steering.attributes
    color_tex    = robj.children[][:attributes]
    preserve(const_lift(cubeside_color, id, mousehover, Signal(start_colors), Signal(color_tex)))
    preserve(id)
    push!(id, robj.children[].id)
    robj
end
