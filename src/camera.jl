

function get_cube_rotations(eyeposition, lookatv)

	dir 		 = eyeposition-lookatv
    xynormal 	 = Vec3f0(0,0,1)
    v       	 = dir-Vec3f0(0,1,0)
    dist    	 = dot(v, xynormal)
    projected_xy = dir - dist*xynormal #project eyeposition onto xy plane
    toxyplane 	 = rotation(dir, projected_xy)
    to_y      	 = rotation(projected_xy, Vec3f0(0,1,0))
    to_x      	 = rotation(projected_xy, Vec3f0(1,0,0))
    to_z      	 = rotation(dir, Vec3f0(0,0,1))
    x_180   	 = Quaternions.qrotation(Vec3f0(1,0,0), deg2rad(180f0))
    z_180   	 = Quaternions.qrotation(Vec3f0(0,0,1), deg2rad(180f0))

    top     = to_y 		* to_z
    bottom  = x_180 	* top
    front   = to_y 		* toxyplane
    back    = z_180 	* front
    left 	= to_x 		* toxyplane
    right  	= z_180 	* left

	top, bottom, front, back, right, left
end


function cubeside_const_lift(_, id, top, bottom, front, back, left, right, h)
    index = h.value[2]
    if h.value[1] == id && index >= 1 && index <= 6
        side =  CubeSides(h.value[2]-1)
        side == TOP     && return top
        side == BOTTOM  && return bottom
        side == FRONT   && return front
        side == BACK    && return back
        side == LEFT    && return left
        side == RIGHT   && return right
    end
    Quaternions.Quaternion(1f0, 0f0, 0f0, 0f0)
end
import Base: +
Base.clamp{T}(x::T) = clamp(x, T(0),T(1))
+{T}(a::RGBA{T}, b::Number) = RGBA{T}(clamp(comp1(a)+b), clamp(comp2(a)+b), clamp(comp3(a)+b), clamp(alpha(a)+b))

function cubeside_color(id, h, startcolors, colortex)
    index = h[2]
    update!(colortex, startcolors)
    if h[1] == id
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
    p = merge(map(GLNormalMesh, quads))
end

Base.middle{T}(r::SimpleRectangle{T}) = Point{2, T}(r.x+(r.w/T(2)), r.y+(r.h/T(2)))


function cubecamera(
		window;
		cube_area 	 = Signal(SimpleRectangle(0,0,150,150)),
		eyeposition  = Vec3f0(2),
    	lookatv 	 = Vec3f0(0),
        trans        = Signal(Vec3f0(0)),
        theta        = Signal(Vec3f0(0))
	)
    const T = Float32
    @materialize mousebuttonspressed, window_size, mouseposition, buttonspressed = window.inputs

    dd = doubleclick(window.inputs[:mousebuttonspressed], 0.2)
    h = window.inputs[:mouse_hover]
    id = Signal(4)
    should_reset = filter(x->h.value[1] == id.value, false, dd)

    p = colored_cube()
    resetto         = const_lift(cubeside_const_lift, should_reset, id, get_cube_rotations(eyeposition, value(lookatv))..., Signal(h))
    inside_trans    = Quaternions.Quaternion(1f0,0f0,0f0,0f0)
    outside_trans   = Quaternions.qrotation(Float32[0,1,0], deg2rad(180f0))
    cube_rotation   = const_lift(cube_area, mouseposition) do ca, mp
        m = minimum(ca)
        max_dist = norm(maximum(ca) - m)
        mindist = max_dist *0.9f0
        maxdist = max_dist *1.5f0
        m, mp = Point{2, Float32}(m), Point{2, Float32}(mp)
        t = norm(m-mp)
        t = Float32((t-mindist)/(maxdist-mindist))
        t = clamp(t, 0f0,1f0)
        slerp(inside_trans, outside_trans, t)
    end
    rect = SimpleRectangle(0f0,0f0, 20f0, 20f0)
    positions = Signal(Point2f0[(0,0), (5,5)])
    scale     = Signal(Vec2f0[(1,1), (1,1)])
    ortho1 = visualize((rect, positions),scale=scale, stroke_width=1f0, transparent_picking = true)
    hovers_ortho = const_lift(h) do h
        h[1] == ortho1.children[].id
    end
    c = const_lift(hovers_ortho) do ho
        ho && return RGBA(0.8f0, 0.8f0, 0.8f0, 0.8f0)
        RGBA(0.5f0, 0.5f0, 0.5f0, 1f0)
    end
    isperspective = foldp(true, mousebuttonspressed) do v0, clicked
        clicked==[0] && hovers_ortho.value && return !v0
        v0
    end

    ortho1.children[][:stroke_color] = c
    const_lift(isperspective) do isp
        if isp
            push!(scale, Vec2f0[(1,1), (0.8,0.8)])
            push!(positions, Point2f0[(0,0), (10,10)])
        else
            push!(scale, Vec2f0[(1,1), (1,1)])
            push!(positions, Point2f0[(0,0), (10,10)])
        end
        nothing
    end
    mprojection = const_lift(isperspective) do isp
        isp && return GLAbstraction.PERSPECTIVE
        GLAbstraction.ORTHOGRAPHIC
    end
    use_cam = const_lift(buttonspressed) do b
        b == [GLFW.KEY_LEFT_CONTROL]
    end
    theta, trans, zoom  = default_camera_control(window.inputs, theta=theta, trans=trans, filtersignal=use_cam)
    far, near, fov      = Signal(100f0), Signal(1f0), Signal(43f0)
    main_cam = PerspectiveCamera(
        window.area,eyeposition,lookatv,
        theta,trans,zoom,fov,near,far,
        mprojection,should_reset,resetto
    )
    window.cameras[:perspective] = main_cam

    piv   = main_cam.pivot
    rot   = const_lift(getfield, piv, :rotation)
    model = const_lift(cube_rotation, const_lift(inv, rot)) do cr, r
        translationmatrix(Vec3f0(3,3,0)) * Mat{4,4,T}(cr) * translationmatrix(Vec3f0(-3,-3,0)) * Mat{4,4,T}(r)
    end
    cubescreen = Screen(window, area=cube_area, transparent=Signal(true))
    cubescreen.cameras[:cube_cam] = DummyCamera(
        farclip=far,
        nearclip=near,
        view=Signal(lookat(eyeposition, value(lookatv), Vec3f0(0,0,1))),
        projection=const_lift(perspectiveprojection, cube_area, fov, near, far)
    )
    robj = visualize(p, model=model, preferred_camera=:cube_cam)
    start_colors = p.attributes
    color_tex    = robj.children[][:attributes]
    preserve(const_lift(cubeside_color, id, h, Signal(start_colors), Signal(color_tex)))

    push!(id, robj.children[].id)
    view(robj, cubescreen);
    view(ortho1, cubescreen, method=:fixed_pixel)
	window
end
