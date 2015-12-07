
function default(main, s, data)
    _default(
    	main, s, merge(Dict(
        :model      	  => eye(Mat4f0),
        :light      	  => Vec3f0[Vec3f0(1.0,1.0,1.0), Vec3f0(0.1,0.1,0.1), Vec3f0(0.9,0.9,0.9), Vec3f0(20,20,20)],
        :preferred_camera => :perspective
    ), data))
end

"""
Creates a default visualization for any value.
The dafaults can be customized via the key word arguments and the style parameter.
The style can change the the look completely (e.g points displayed as lines, or particles),
while the key word arguments just alter the parameters of one visualization.
Always returns a context, which can be displayed on a window via view(::Context, [display]).
"""
visualize(main, s::Symbol=:default; kw_args...) = visualize(main, Style{s}(), Dict{Symbol, Any}(kw_args))::Context
function visualize(main, s::Style, data::Dict)
	assemble_shader(default(main, s, data))::Context
end
visualize(c::Composable) = Context(c)
visualize(c::Context) = c




function view(
		robj::RenderObject, screen=ROOT_SCREEN;
		method 	 = robj.uniforms[:preferred_camera],
		position = Vec3f0(2), lookat=Vec3f0(0)
	)
    if haskey(screen.cameras, method)
        camera = screen.cameras[method]
    elseif method == :perspective
		camera = PerspectiveCamera(screen.inputs, position, lookat)
	elseif method == :fixed_pixel
		camera = DummyCamera(window_size=screen.area)
	elseif method == :orthographic_pixel
		camera = OrthographicPixelCamera(screen.inputs)
	elseif method == :nothing
		return push!(screen.renderlist, robj)
	else
         error("Method $method not a known camera type")
	end
	merge!(robj.uniforms, collect(camera), Dict( # add a view display dependant values
		:resolution => const_lift(Vec2f0, screen.inputs[:framebuffer_size]),
		:fixed_projectionview => get(screen.cameras, :fixed_pixel, DummyCamera(window_size=screen.area)).projectionview
	))
	push!(screen.renderlist, robj)
end

view(robjs::Vector{RenderObject}, screen=ROOT_SCREEN; kw_args...) = for robj in robjs
	view(robj, screen; kw_args...)
end
view(c::Composable, screen=ROOT_SCREEN; kw_args...) = view(extract_renderable(c), screen; kw_args...)

"""
default returns common defaults for a certain style and datatype.
This is convenient, to quickly switch out default styles.
"""
default{T}(::T, s::Style=Style{:default}()) = default(T, s)

const color_defaults = RGBA{Float32}[
	RGBA{Float32}(0.0f0,0.74736935f0,1.0f0,1.0f0),
	RGBA{Float32}(0.78, 0.01, 0.93, 1.0),
	RGBA{Float32}(0, 0, 0, 1.0),
	RGBA{Float32}(0.78, 0.01, 0, 1.0)
]
function default{T <: Colorant}(::Type{T}, s::Style=Style{:default}(), index=1)
    index>length(color_defaults) && error("There are only three color defaults.")
    color_defaults[index]
end
default{T <: Colorant}(::Type{Vector{T}}, s::Style=Style{:default}()) = convert(Array{RGBA{U8}, 1}, map(x->RGBA{U8}(x, 1.0), colormap("Blues")))
