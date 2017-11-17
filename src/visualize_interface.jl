
const _default_light = Vec3f0[Vec3f0(1.0,1.0,1.0), Vec3f0(0.1,0.1,0.1), Vec3f0(0.9,0.9,0.9), Vec3f0(20,20,20)]
function default(main::ANY, s::ANY, data::ANY)
    data = _default(main, s, copy(data))
    @gen_defaults! data begin # make sure every object has these!
        model = eye(Mat4f0)
        light = _default_light
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
visualize(main::ANY, s::Symbol=:default; kw_args...) = visualize(main, Style{s}(), Dict{Symbol, Any}(kw_args))::Context
visualize(main::ANY, s::Style, data::Dict) = assemble_shader(default(main, s, data))::Context
visualize(c::Composable, s::Symbol=:default; kw_args...) = Context(c)
visualize(c::Composable, s::Style, data::Dict) = Context(c)

visualize(c::Context, s::Symbol=:default; kw_args...) = c
visualize(c::Context, s::Style, data::Dict) = c
#

function _view(
        robj::RenderObject, screen = current_screen();
        camera = robj.uniforms[:preferred_camera],
        position = Vec3f0(2), lookat = Vec3f0(0)
    )
    global _camera_counter
    local camsym::Symbol # make things type stable
    mouseinside = screen.inputs[:mouseinside]
    ishidden = screen.hidden
    if isa(camera, Symbol)
        camsym = camera::Symbol
        if haskey(screen.cameras, camsym)
            real_camera = screen.cameras[camsym]
        elseif camsym == :perspective
            keep = map((a, b) -> !a && b, ishidden, mouseinside)
            real_camera = PerspectiveCamera(screen.inputs, position, lookat, keep = keep)
        elseif camsym == :fixed_pixel
            real_camera = DummyCamera(window_size = screen.area)
        elseif camsym == :orthographic_pixel
            keep = map((a, b) -> !a && b, ishidden, mouseinside)
            real_camera = OrthographicPixelCamera(screen.inputs, keep = keep)
        elseif camsym == :nothing
            push!(screen, robj, :nothing)
            return nothing
        else
            error("Camera symbol $camera not known")
        end
    elseif isa(camera, Camera)
        camsym = :custom
        real_camera = camera
    else
         error("$camera not a known camera type")
    end
    screen.cameras[camsym] = real_camera
    robj.uniforms[:resolution] = map(screen.area) do area
        Vec2f0(widths(area))
    end
    collect(real_camera, robj.uniforms)
    push!(screen, robj)
    nothing
end

_view(robjs::Vector, screen = current_screen(); kw_args...) = for robj in robjs
    _view(robj, screen; kw_args...)
end
_view(c::Composable, screen = current_screen(); kw_args...) = _view(extract_renderable(c), screen; kw_args...)
