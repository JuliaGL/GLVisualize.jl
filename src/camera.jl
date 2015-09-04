


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

@enum CubeSides TOP BOTTOM FRONT BACK RIGHT LEFT



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


function cubecamera(
		window,
		cube_area 	= Input(Rectangle(0,0,150,150)),
		eyeposition = Vec3f0(2),
    	lookatv 	= Vec3f0(0)
	)

    dd = doubleclick(window.inputs[:mousebuttonspressed], 0.1);
    h = window.inputs[:mouse_hover];
    id = Input(4)
    m = filter(x->h.value[1] == id.value, false, dd);
    @materialize mouseposition, mousebuttonspressed, buttonspressed, scroll_y, window_size = window.inputs
    const T = Float32;
    
    mouseposition   	= lift(Vec{2, T}, mouseposition);
    clickedwithoutkeyL 	= lift(GLAbstraction.mousepressed_without_keyboard, mousebuttonspressed, Input(0), buttonspressed)
    clickedwithoutkeyM 	= lift(GLAbstraction.mousepressed_without_keyboard, mousebuttonspressed, Input(2), buttonspressed)
    nokeydown 			= lift(isempty,    buttonspressed);
    anymousedown 		= lift(isnotempty, mousebuttonspressed);
    mousedraggdiffL 	= lift(last, foldl(GLAbstraction.mousediff, (false, Vec2f0(0.0f0), Vec2f0(0.0f0)), clickedwithoutkeyL, mouseposition));
    mousedraggdiffM 	= lift(last, foldl(GLAbstraction.mousediff, (false, Vec2f0(0.0f0), Vec2f0(0.0f0)), clickedwithoutkeyM, mouseposition));

    theta       = lift(GLAbstraction.thetalift, mousedraggdiffL, 50f0)
    xtrans      = lift(/, scroll_y, 5f0)
    ytrans      = lift(/, lift(first, mousedraggdiffM), 200f0)
    ztrans      = lift(/, lift(last, mousedraggdiffM), -200f0)
    trans       = lift(Vec{3, T}, xtrans, ytrans, ztrans)

    far, near, fov = Input(100f0), Input(1f0), Input(43f0);


    xdir 	= Vec3f0(1f0,0f0,0f0)
    ydir 	= Vec3f0(0f0,1f0,0f0)
    zdir 	= Vec3f0(0f0,0f0,1f0)
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



    resetto = lift(cubeside_lift, m, id, get_cube_rotations(eyeposition, lookatv)..., Input(h))

    ortho1 = visualize(Rectangle(0f0,0f0, 20f0, 20f0), thickness=1f0)
    ortho2 = visualize(Rectangle(5f0,5f0, 20f0, 20f0), thickness=1f0)
    hovers_ortho = lift(h) do h
        h[1] == ortho1.id || h[1] == ortho2.id
    end
    c = lift(hovers_ortho) do ho
        ho && return RGBA(1f0, 1f0, 1f0, 1f0)
        RGBA(0.9f0, 0.9f0, 0.9f0, 1f0)
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

    main_cam = PerspectiveCamera(
        window.area,
        Vec3f0(2),
        Vec3f0(0),
        theta,
        trans,
        fov,
        near,
        far,
        mprojection,
        m,
        resetto
    )
    window.cameras[:perspective] = main_cam

    cubescreen = Screen(window, area=cube_area);
    piv = main_cam.pivot;
    rot   = lift(getfield, piv, :rotation);
    model = lift(inv, lift(rotationmatrix4, rot))

    cam = DummyCamera(
        farclip=far,
        nearclip=near,
        view=Input(lookat(Vec3f0(2), Vec3f0(0), Vec3f0(0,0,1))),
        projection=lift(perspectiveprojection, cubescreen.area, fov, near, far)
    );

    cubescreen.cameras[:cam_cube] = cam;

    robj = visualize(p, model=model, preferred_camera=:cam_cube);



    push!(id, robj.id)
    view(robj, cubescreen);
    view(ortho1, cubescreen, method=:fixed_pixel);
    view(ortho2, cubescreen, method=:fixed_pixel);
	cubescreen
end
