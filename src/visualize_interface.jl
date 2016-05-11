function default(main, s, data)
    data = _default(main, s, copy(data))
    @gen_defaults! data begin # make sure every object has these!
        model      	     = eye(Mat4f0)
        light      	     = Vec3f0[Vec3f0(1.0,1.0,1.0), Vec3f0(0.1,0.1,0.1), Vec3f0(0.9,0.9,0.9), Vec3f0(20,20,20)]
        preferred_camera = :perspective
        is_transparent_pass = Cint(false)
    end
end

"""
Creates a default visualization for any value.
The defaults can be customized via the key word arguments and the style parameter.
The style can change the the look completely (e.g points displayed as lines, or particles),
while the key word arguments just alter the parameters of one visualization.
Always returns a context, which can be displayed on a window via view(::Context, [display]).
"""
visualize(main, s::Symbol=:default; kw_args...) = visualize(main, Style{s}(), Dict{Symbol, Any}(kw_args))::Context
visualize(main, s::Style, data::Dict) = assemble_shader(default(main, s, data))::Context
visualize(c::Composable) = Context(c)
visualize(c::Context) = c

function Base.push!(screen::Screen, robj::RenderObject)
    # only add to renderlist if not already in there
    if !(in(robj, screen.renderlist))
        push!(screen.renderlist, robj)
        if Bool(get(robj.uniforms, :is_fully_opaque, true))
            push!(screen.opaque, length(screen.renderlist))
        else
            push!(screen.transparent, length(screen.renderlist))
        end
    end
    nothing
end

function view(
		robj::RenderObject, screen=current_screen();
		camera = robj.uniforms[:preferred_camera],
		position = Vec3f0(2), lookat=Vec3f0(0)
	)
    if isa(camera, Camera)
    	real_camera = camera
    elseif haskey(screen.cameras, camera)
        real_camera = screen.cameras[camera]
    elseif camera == :perspective
        inside = screen.inputs[:mouseinside]
		real_camera = PerspectiveCamera(screen.inputs, position, lookat, keep=inside)
	elseif camera == :fixed_pixel
		real_camera = DummyCamera(window_size=screen.area)
	elseif camera == :orthographic_pixel
        inside = screen.inputs[:mouseinside]
        real_camera = OrthographicPixelCamera(screen.inputs, keep=inside)
	elseif camera == :nothing
        push!(screen, robj)
		return nothing
	else
         error("Method $camera not a known camera type")
	end
    screen.cameras[Symbol(string(camera))] = real_camera
	merge!(robj.uniforms, collect(real_camera), Dict( # add display dependant values
		:resolution => const_lift(Vec2f0, const_lift(x->Vec2f0(x.w,x.h), screen.area)),
		:fixed_projectionview => get(screen.cameras, :fixed_pixel, DummyCamera(window_size=screen.area)).projectionview
	))
    push!(screen, robj)
	nothing
end

view(robjs::Vector, screen=current_screen(); kw_args...) = for robj in robjs
	view(robj, screen; kw_args...)
end
view(c::Composable, screen=current_screen(); kw_args...) = view(extract_renderable(c), screen; kw_args...)
