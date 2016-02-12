function default(main, s, data)
    data = _default(main, s, copy(data))
    @gen_defaults! data begin # make sure every object has these!
        model      	     = eye(Mat4f0)
        light      	     = Vec3f0[Vec3f0(1.0,1.0,1.0), Vec3f0(0.1,0.1,0.1), Vec3f0(0.9,0.9,0.9), Vec3f0(20,20,20)]
        preferred_camera = :perspective
    end
end

"""
Creates a default visualization for any value.
The dafaults can be customized via the key word arguments and the style parameter.
The style can change the the look completely (e.g points displayed as lines, or particles),
while the key word arguments just alter the parameters of one visualization.
Always returns a context, which can be displayed on a window via view(::Context, [display]).
"""
visualize(main, s::Symbol=:default; kw_args...) = visualize(main, Style{s}(), Dict{Symbol, Any}(kw_args))::Context
visualize(main, s::Style, data::Dict) = assemble_shader(default(main, s, data))::Context
visualize(c::Composable) = Context(c)
visualize(c::Context) = c


function view(
		robj::RenderObject, screen=ROOT_SCREEN;
		camera = robj.uniforms[:preferred_camera],
		position = Vec3f0(2), lookat=Vec3f0(0)
	)
    if isa(camera, Camera)
    	real_camera = camera
    elseif haskey(screen.cameras, camera)
        real_camera = screen.cameras[camera]
    elseif camera == :perspective
		real_camera = PerspectiveCamera(screen.inputs, position, lookat)
	elseif camera == :fixed_pixel
		real_camera = DummyCamera(window_size=screen.area)
	elseif camera == :orthographic_pixel
        fov, near = 41f0, 1f0
        theta, trans, up, fov_s, near_s = map(Signal,
            (Vec3f0(0), Vec3f0(0), Vec3f0(0,1,0), fov, near)
        )
        area = value(screen.area)
        h = Float32(tan(fov / 360.0 * pi) * near)
        w_, h_ = area.w/2f0, area.h/2f0
        zoom = min(h_,w_)/h
        x, y = w_, h_
        eyeposition = Signal(Vec3f0(x, y, zoom))
        lookatvec   = Signal(Vec3f0(x, y, 0))
        farclip     = Signal(zoom*2.0f0)

        real_camera = PerspectiveCamera(
            theta,
            trans,
            lookatvec,
            eyeposition,
            up,
            screen.area,
            fov_s, # Field of View
            near_s,  # Min distance (clip distance)
            farclip, # Max distance (clip distance)
            Signal(GLAbstraction.ORTHOGRAPHIC)
        )

	elseif camera == :nothing
		return push!(screen.renderlist, robj)
	else
         error("Method $camera not a known camera type")
	end
    screen.cameras[camera] = real_camera
	merge!(robj.uniforms, collect(real_camera), Dict( # add display dependant values
		:resolution => const_lift(Vec2f0, const_lift(x->Vec2f0(x.w,x.h), screen.area)),
		:fixed_projectionview => get(screen.cameras, :fixed_pixel, DummyCamera(window_size=screen.area)).projectionview
	))
	push!(screen.renderlist, robj)
end

view(robjs::Vector{RenderObject}, screen=ROOT_SCREEN; kw_args...) = for robj in robjs
	view(robj, screen; kw_args...)
end
view(c::Composable, screen=ROOT_SCREEN; kw_args...) = view(extract_renderable(c), screen; kw_args...)
