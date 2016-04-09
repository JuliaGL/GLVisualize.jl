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
Base.clamp{T}(x::T) = clamp(x, T(0),T(1))
+{T}(a::RGBA{T}, b::Number) = RGBA{T}(clamp(comp1(a)+b), clamp(comp2(a)+b), clamp(comp3(a)+b), clamp(alpha(a)+b))

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

Base.middle{T}(r::SimpleRectangle{T}) = Point{2, T}(r.x+(r.w/T(2)), r.y+(r.mousehover/T(2)))

"""
creates a button that can switch between orthographic and perspective projection
"""
function projection_switch(width, mousehover, mouse_buttons_pressed;
        color=RGBA{Float32}(0,0,0,0),
        stroke_width=1.5f0
    )
    # we use two overlapping rectangles as a symbol for the two projections
    positions = Signal(Point2f0[(0,0), (10,10)])
    scale     = Signal(Vec2f0[(width, width), (width,width)])
    ortho1    = visualize(
        (RECTANGLE, positions), color=color,
        scale=scale, stroke_width=stroke_width, transparent_picking=true
    )
    ortho_robj = ortho1.children[]
    # find out if we hover over the the button
    hovers_ortho = const_lift(mousehover) do mh
        mh.id == ortho_robj.id
    end
    # change the color when we're hovering over the button
    stroke_color = const_lift(hovers_ortho) do ho
        ho && return RGBA(0.8f0, 0.8f0, 0.8f0, 0.8f0)
        RGBA(0.5f0, 0.5f0, 0.5f0, 1f0)
    end
    # overwrite the stroke color attribute
    ortho_robj[:stroke_color] = stroke_color

    # find out if the button was pressed and if yes, switch the projection
    isperspective = foldp(true, mouse_buttons_pressed) do v0, clicked
        clicked==Set([0]) && value(hovers_ortho) && return !v0
        v0
    end

    projectiontype = map(isperspective) do isp
        if isp
            # for perspective, the back rectangle is a little smaller
            # (like in a perspective projection)
            push!(scale, Vec2f0[(width,width), (width*0.8,width*0.8)])
        else
            # for orthographic, both have the same size
            push!(scale, fill(Vec2f0(width), 2))
        end
        # return the correct projection type
        isp && return GLAbstraction.PERSPECTIVE
        GLAbstraction.ORTHOGRAPHIC
    end
    return projectiontype, ortho1
end


"""
Creates a camera which is steered by a cube for `window`.
"""
function cubecamera(
		window;
		cube_area 	= Signal(SimpleRectangle(0,0,150,150)),
		eyeposition = Vec3f0(2),
    	lookatv 	= Vec3f0(0),
        trans       = Signal(Vec3f0(0)),
        theta       = Signal(Vec3f0(0))
	)
    const T = Float32
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
    projectiontype, projectionbutton = projection_switch(20f0, mousehover, mouse_buttons_pressed)
    inside_trans  = Quaternions.Quaternion(1f0,0f0,0f0,0f0)
    outside_trans = Quaternions.qrotation(Float32[0,1,0], deg2rad(180f0))
    cube_rotation = const_lift(cube_area, mouseposition) do ca, mp
        m = minimum(ca)
        max_dist = norm(maximum(ca) - m)
        mindist = max_dist *0.9f0
        maxdist = max_dist *1.5f0
        m, mp = Point2f0(m), Point2f0(mp)
        t = norm(m-mp)
        t = Float32((t-mindist)/(maxdist-mindist))
        t = clamp(t, 0f0,1f0)
        slerp(inside_trans, outside_trans, t)
    end

    left_ctrl = Set([GLFW.KEY_LEFT_CONTROL])
    use_cam = const_lift(buttons_pressed) do b
        b == left_ctrl
    end
    theta, trans = default_camera_control(
        window.inputs, Signal(0.02f0), Signal(0.01f0),
        use_cam
    )
    far, near, fov, upvector = map(Signal, (100f0, 1f0, 43f0, Vec3f0(0,0,1)))
    lookatvec, eyeposition =  Signal(lookatv), Signal(eyeposition)
    main_cam = PerspectiveCamera(
        theta ,trans, lookatvec, eyeposition, upvector,
        window.area, fov, near, far,
        projectiontype
    )
    preserve(map(new_eyeposition) do neweyepos
        dir = value(eyeposition)-value(lookatvec)
        oldlength = norm(dir)
        push!(lookatvec, lookatv)
        push!(eyeposition, neweyepos*oldlength) # neweyepos should be normalized
        for i=1:3
            unitvec = unit(Vec3f0, i)
            if dot(neweyepos, unitvec) == 0f0 # find an orthogonal vector
                push!(upvector,unitvec)
            end
        end
    end)
    window.cameras[:perspective] = main_cam

    cubescreen = Screen(window, area=cube_area, color=RGBA{Float32}(0,0,0,0))
    viewmatrix = map(eyeposition, lookatvec) do eyepos, lvec
        dir = GeometryTypes.normalize(eyepos-lvec)
        lookat(dir*2, Vec3f0(0), value(upvector))
    end
    cubescreen.cameras[:cube_cam] = DummyCamera(
        farclip=far,
        nearclip=near,
        view=viewmatrix,
        projection=const_lift(perspectiveprojection, cube_area, fov, near, far)
    )
    
    robj = visualize(cube_steering, preferred_camera=:cube_cam, model=scalematrix(Vec3f0(0.5)))
    start_colors = cube_steering.attributes
    color_tex    = robj.children[][:attributes]
    preserve(const_lift(cubeside_color, id, mousehover, Signal(start_colors), Signal(color_tex)))
    preserve(id)
    push!(id, robj.children[].id)
    view(robj, cubescreen)
    view(projectionbutton, cubescreen, camera=:fixed_pixel)
	window
end
