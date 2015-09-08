@enum CubeSides TOP BOTTOM FRONT BACK RIGHT LEFT


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


function cubeside_lift(_, id, top, bottom, front, back, left, right, h)
    if h.value[1] == id && h.value[2] >= 0 && h.value[2] <= 5
        side =  CubeSides(h.value[2])
        side == TOP     && return top
        side == BOTTOM  && return bottom
        side == FRONT   && return front
        side == BACK    && return back
        side == LEFT    && return left
        side == RIGHT   && return right
    end
    Quaternions.Quaternion(1f0, 0f0, 0f0, 0f0)
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


function fit(target::AABB, actual::AABB)
    w1, w2 = width(target), width(actual)
    move_diff = minimum(actual)-minimum(target)
    scalematrix(w1-w2)*translationmatrix(move_diff)
end

function cubecamera{T}(
		window,
		cube_area 	           = Input(Rectangle(0,0,150,150)),
		eyeposition::Vec{3,T}  = Vec3f0(2),
    	lookatv::Vec{3,T} 	   = Vec3f0(0)
	)
    @materialize mousebuttonspressed, window_size = window.inputs
    
    dd = doubleclick(window.inputs[:mousebuttonspressed], 0.1);
    h = window.inputs[:mouse_hover]
    id = Input(4)
    m = filter(x->h.value[1] == id.value, false, dd);
    
    p = colored_cube()

    resetto = lift(cubeside_lift, m, id, get_cube_rotations(eyeposition, lookatv)..., Input(h))

    ortho1 = visualize(Rectangle(0f0,0f0, 20f0, 20f0), thickness=1f0)
    ortho2 = visualize(Rectangle(5f0,5f0, 20f0, 20f0), thickness=1f0)
    hovers_ortho = lift(h) do h
        h[1] == ortho1.id || h[1] == ortho2.id
    end
    c = lift(hovers_ortho) do ho
        ho && return RGBA(0.8f0, 0.8f0, 0.8f0, 0.8f0)
        RGBA(0.5f0, 0.5f0, 0.5f0, 1f0)
    end
    isperspective = foldl(true, mousebuttonspressed) do v0, clicked
        clicked==[0] && hovers_ortho.value && return !v0
        v0
    end

    ortho1[:color] = c
    ortho2[:color] = c
    ortho2[:model] = lift(isperspective) do isp
        isp && return translationmatrix(Vec3f0(5,5,0))*scalematrix(Vec3f0(0.8))
        scalematrix(Vec3f0(1.0))
    end
    mprojection = lift(isperspective) do isp
        isp && return GLAbstraction.PERSPECTIVE
        GLAbstraction.ORTHOGRAPHIC
    end

    theta, trans, zoom  = default_camera_control(window.inputs)
    far, near, fov      = Input(100f0), Input(1f0), Input(43f0)
    main_cam = PerspectiveCamera(
        window.area,eyeposition,lookatv,
        theta,trans,zoom,fov,near,far,
        mprojection,m,resetto
    )
    window.cameras[:perspective] = main_cam

    piv   = main_cam.pivot;
    rot   = lift(getfield, piv, :rotation)
    model = lift(inv, lift(rotationmatrix4, rot))
    cubescreen = Screen(window, area=cube_area)
    cubescreen.cameras[:cube_cam] = DummyCamera(
        farclip=far,
        nearclip=near,
        view=Input(lookat(eyeposition, lookatv, Vec3f0(0,0,1))),
        projection=lift(perspectiveprojection, cube_area, fov, near, far)
    )
    robj = visualize(p, model=model, preferred_camera=:cube_cam)


    push!(id, robj.id)
    view(robj, cubescreen);
    view(ortho1, cubescreen, method=:fixed_pixel);
    view(ortho2, cubescreen, method=:fixed_pixel);
	window
end
