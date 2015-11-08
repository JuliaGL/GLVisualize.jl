typealias VecTypes{T} Union{Vector{T}, Texture{T}, Signal{Vector{T}}}
typealias MatTypes{T} Union{Matrix{T}, Texture{T, 2}, Signal{Matrix{T}}}
typealias VolumeTypes{T} Union{Array{T, 3}, Texture{T, 3}, Signal{Array{T, 3}}}


typealias VecOrSig{T} Union{Vector{T}, Signal{Vector{T}}}
typealias MatOrSig{T} Union{Matrix{T}, Signal{Matrix{T}}}
typealias VolumeOrSig{T} Union{Array{T, 3}, Signal{Array{T, 3}}}

visualize_default(value::Any, style::Style, kw_args=Dict{Symbol, Any}) = error("""There are no defaults for the type $(typeof(value)),
	which either means the implementation is incomplete or not implemented yet.
	Consider defining visualize_default(::$(typeof(value)), ::Style, parameters::Dict{Symbol, Any}) => Dict{Symbol, Any} and
	visualize(::$(typeof(value)), ::Style, parameters::Dict{Symbol, Any}) => RenderObject""")

function visualize_default(
		value::Any, style::Symbol, kw_args::Dict{Symbol, Any},
		defaults=Dict(
		    :model      	  => Signal(eye(Mat4f0)),
		    :light      	  => Signal(Vec3f0[Vec3f0(1.0,1.0,1.0), Vec3f0(0.1,0.1,0.1), Vec3f0(0.9,0.9,0.9), Vec3f0(20,20,20)]),
		    :preferred_camera => :perspective
		)
	)
	parameters_calculated = _default(value, Style{style}(), parameters_dict)
	merge(defaults, parameters_calculated, parameters_dict)
end


"""
Creates a default visualization for any value.
The dafaults can be customized via the key word arguments and the style parameter.
The style can change the the look completely (e.g points displayed as lines, or particles),
while the key word arguments just alter the parameters of one visualization.
Always returns a context, which can be displayed on a window via view(::Context, [display]).
"""
visualize(value::Any, style::Symbol=:default; kw_args...) =
    visualize(value::Any, Style{style}(), Dict{Symbol, Any}(kw_args)) # convert to internally used format

function visualize(value::Any, style::Style, parameters::Dict)
    parameters[:origin] = value # preserve origin value... maybe this should be via weak reference?
	visualize(
		gl_convert(value),
		style,
		visualize_default(value, style, parameters)
	)::Context
end

visualize(c::Composable) = c


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
default{T}(::T, s::Style) = default(T, s)
default{T <: Colorant}(::Type{T}, s::Style) = RGBA{Float32}(0.0f0,0.74736935f0,1.0f0,1.0f0)
default{T <: Colorant}(::Type{Vector{T}}, s::Style) = map(x->RGBA{U8}(x, 1.0), colormap("Blues", 20))
