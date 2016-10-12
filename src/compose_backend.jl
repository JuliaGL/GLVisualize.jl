module ComposeBackend
using GLAbstraction, GLFW, GLWindow, Measures, GLVisualize, GeometryTypes, Colors, Reactive, ModernGL
importall Compose

type GLVisualizePropertyState
    stroke::RGBA{Float32}
    fill::RGBA{Float32}
    stroke_dash::Array{Float32,1}
    stroke_linecap::Compose.LineCap
    stroke_linejoin::Compose.LineJoin
    visible::Bool
    linewidth::AbsoluteLength
    fontsize::AbsoluteLength
    font::AbstractString
    clip::Nullable{Compose.ClipPrimitive}
end
type GLVisualizePropertyFrame
    # Vector properties in this frame.
    vector_properties::Dict{Type, Compose.Property}

    # True if this property frame has scalar properties. Scalar properties are
    # emitted as a group (<g> tag) that must be closed when the frame is popped.
    has_scalar_properties::Bool

    function GLVisualizePropertyFrame()
        return new(Dict{Type, Compose.Property}(), false)
    end
end

type GLVisualizeBackend <: Compose.Backend
    screen
    stroke::RGBA{Float32}
    fill::RGBA{Float32}
    stroke_dash::Array{Float32,1}
    stroke_linecap::Compose.LineCap
    stroke_linejoin::Compose.LineJoin
    visible::Bool
    linewidth::AbsoluteLength
    fontsize::AbsoluteLength
    font::AbstractString
    clip::Nullable{Compose.ClipPrimitive}
    ppmm::Vec2f0

    # Keep track of property
    state_stack::Vector{GLVisualizePropertyState}
    property_stack::Vector{GLVisualizePropertyFrame}
    vector_properties::Dict{Type, Nullable{Compose.Property}}
    function GLVisualizeBackend(screen)
        img = new()
        img.screen = screen
        img.stroke = Compose.default_stroke_color == nothing ?
                        RGBA{Float32}(0, 0, 0, 0) : convert(RGBA{Float32},  Compose.default_stroke_color)
        img.fill   =  Compose.default_fill_color == nothing ?
                        RGBA{Float32}(0, 0, 0, 0) : convert(RGBA{Float32},  Compose.default_fill_color)
        img.stroke_dash = []
        img.stroke_linecap = Compose.LineCapButt()
        img.stroke_linejoin = Compose.LineJoinMiter()
        img.visible = true
        img.linewidth = Compose.default_line_width
        img.fontsize = Compose.default_font_size
        img.font = Compose.default_font_family
        img.clip = Nullable{Compose.ClipPrimitive}()

        img.state_stack = Array(GLVisualizePropertyState, 0)
        img.property_stack = Array(GLVisualizePropertyFrame, 0)
        img.vector_properties = Dict{Type, Nullable{Compose.Property}}()

        m = GLFW.GetPrimaryMonitor()
        props = GLWindow.MonitorProperties(m)
        img.ppmm = Vec2f0(props.dpi/25.4f0)

        img
    end

end
function Measures.width(img::GLVisualizeBackend)
    ((img.screen.inputs[:framebuffer_size].value[1]) / img.ppmm[1]) * mm
end

function Measures.height(img::GLVisualizeBackend)
    ((img.screen.inputs[:framebuffer_size].value[2]) / img.ppmm[2]) * mm
end

function Compose.root_box(img::GLVisualizeBackend)
    BoundingBox(Measures.width(img), Measures.height(img))
end
function absolute_native_units(img::GLVisualizeBackend, u::Float64)
    Float32(img.ppmm[1] * u)
end
function absolute_native_units{T}(img::GLVisualizeBackend, u::Length{:mm, T})
    Float32(img.ppmm[1] * u.value)
end
function absolute_native_units{T}(img::GLVisualizeBackend, u::Tuple{Length{:mm, T},Length{:mm, T}})
    Point2f0(u[1].value, (Measures.width(img)-u[2]).value).*Point2f0(img.ppmm)
end
relative_native_units{T}(img::GLVisualizeBackend, u::Tuple{Length{:mm, T},Length{:mm, T}}) = Point2f0(u[1].value, u[2].value).*Point2f0(img.ppmm)

export absolute_native_units

function Compose.push_property_frame(img::GLVisualizeBackend, properties::Vector{Compose.Property})
    if isempty(properties)
        return
    end

    frame = GLVisualizePropertyFrame()
    applied_properties = Set{Type}()
    scalar_properties = Array(Compose.Property, 0)
    for property in properties
        if Compose.isscalar(property) && !(typeof(property) in applied_properties)
            push!(scalar_properties, property)
            push!(applied_properties, typeof(property))
            frame.has_scalar_properties = true
        elseif !Compose.isscalar(property)
            frame.vector_properties[typeof(property)] = property
            img.vector_properties[typeof(property)] = property
        end
    end
    push!(img.property_stack, frame)
    if isempty(scalar_properties)
        return
    end

    save_property_state(img)
    for property in scalar_properties
        apply_property(img, property.primitives[1])
    end
end

function Compose.pop_property_frame(img::GLVisualizeBackend)
    @assert !isempty(img.property_stack)
    frame = pop!(img.property_stack)

    if frame.has_scalar_properties
        restore_property_state(img)
    end

    for (propertytype, property) in frame.vector_properties
        img.vector_properties[propertytype] = Nullable{Compose.Property}()
        for i in length(img.property_stack):-1:1
            if haskey(img.property_stack[i].vector_properties, propertytype)
                img.vector_properties[propertytype] =
                    img.property_stack[i].vector_properties[propertytype]
            end
        end
    end
end



# Return true if the vector properties need to be pushed and popped, rather
# than simply applied.
function vector_properties_require_push_pop(img::GLVisualizeBackend)
    for (propertytype, property) in img.vector_properties
        propertytype
        if in(propertytype, [Compose.Property{Compose.FontPrimitive},
                             Compose.Property{Compose.FontSizePrimitive},
                             Compose.Property{Compose.ClipPrimitive}])
            return true
        end
    end
    return false
end

function save_property_state(img::GLVisualizeBackend)
    push!(img.state_stack,
        GLVisualizePropertyState(
            img.stroke,
            img.fill,
            img.stroke_dash,
            img.stroke_linecap,
            img.stroke_linejoin,
            img.visible,
            img.linewidth,
            img.fontsize,
            img.font,
            img.clip))
end


function restore_property_state(img::GLVisualizeBackend)
    state = pop!(img.state_stack)
    img.stroke = state.stroke
    img.fill = state.fill
    img.stroke_dash = state.stroke_dash
    img.stroke_linecap = state.stroke_linecap
    img.stroke_linejoin = state.stroke_linejoin
    img.visible = state.visible
    img.linewidth = state.linewidth
    img.fontsize = state.fontsize
    img.font = state.font
    img.clip = state.clip
end


function push_vector_properties(img::GLVisualizeBackend, idx::Int)
    save_property_state(img)
    for (propertytype, property) in img.vector_properties
        if isnull(property)
            continue
        end
        primitives = get(property).primitives
        if idx > length(primitives)
            error("Vector form and vector property differ in length. Can't distribute.")
        end
        apply_property(img, primitives[idx])
    end
end

apply_property(img::GLVisualizeBackend, p) = nothing # ignore unsupported properties

function pop_vector_properties(img::GLVisualizeBackend)
    restore_property_state(img)
end


function apply_property(img::GLVisualizeBackend, p::Compose.StrokePrimitive)
    img.stroke = p.color
end


function apply_property(img::GLVisualizeBackend, p::Compose.FillPrimitive)
    img.fill = p.color
end


function apply_property(img::GLVisualizeBackend, p::Compose.FillOpacityPrimitive)
    img.fill = RGBA{Float32}(color(img.fill), p.value)
end


function apply_property(img::GLVisualizeBackend, p::Compose.StrokeOpacityPrimitive)
    img.stroke = RGBA{Float32}(color(img.stroke), p.value)
end


function apply_property(img::GLVisualizeBackend, p::Compose.StrokeDashPrimitive)
    img.stroke_dash = map(v -> absolute_native_units(img, v.value), p.value)
end


function apply_property(img::GLVisualizeBackend, p::Compose.StrokeLineCapPrimitive)
    img.stroke_linecap = p.value
end


function apply_property(img::GLVisualizeBackend, p::Compose.StrokeLineJoinPrimitive)
    img.stroke_linejoin = p.value
end


function apply_property(img::GLVisualizeBackend, p::Compose.VisiblePrimitive)
    img.visible = p.value
end


function apply_property(img::GLVisualizeBackend, property::Compose.LineWidthPrimitive)
    img.linewidth = property.value
end


function apply_property(img::GLVisualizeBackend, property::Compose.FontPrimitive)
    img.font = property.family
    #=
    font_desc = ccall((:pango_layout_get_font_description, Cairo._jl_libpango),
                      Ptr{Void}, (Ptr{Void},), img.ctx.layout)

    if font_desc == C_NULL
        size = absolute_native_units(img, default_font_size.value)
    else
        size = ccall((:pango_font_description_get_size, Cairo._jl_libpango),
                     Cint, (Ptr{Void},), font_desc)
    end

    Cairo.set_font_face(img.ctx,
        @sprintf("%s %0.2fpx", property.family, size / PANGO_SCALE))
    =#
end


function apply_property(img::GLVisualizeBackend, property::Compose.FontSizePrimitive)
    img.fontsize = property.value

    #=
    Cairo.set_font_face(img.ctx,
        @sprintf("%s %.2fpx",
            family, absolute_native_units(img, property.value.value)))
    =#
end


function apply_property(img::GLVisualizeBackend, property::Compose.ClipPrimitive)
    if isempty(property.points); return; end
end

Compose.isfinished(backend::GLVisualizeBackend) = false
Compose.finish(backend::GLVisualizeBackend) = nothing

Compose.iswithjs(img::GLVisualizeBackend) = false
Compose.iswithousjs(img::GLVisualizeBackend) = true

function Compose.draw{T <: Compose.CirclePrimitive}(img::GLVisualizeBackend, form::Compose.Form{T})
    r = form.primitives[1].radius
    radius = absolute_native_units(img, r)
    positions = Point2f0[absolute_native_units(img, elem.center) for elem in form.primitives]
    _view(visualize((Circle{Float32}(Point2f0(0), radius), positions),
    	color=img.fill,
    	stroke_color=img.stroke,
    	visible=img.visible
    ), img.screen, camera=:orthographic_pixel)
end
#=
function Compose.draw{T <: Compose.RectanglePrimitive}(img::GLVisualizeBackend, form::Compose.Form{T})
    positions = [absolute_native_units(img, elem.corner) for elem in form.primitives]
    wh = form.primitives[1].width, form.primitives[1].height
    scale = absolute_native_units(img, wh)
    _view(visualize(positions,
    	scale=scale,
    	shape=Cint(RECTANGLE),
    	model=translationmatrix(Vec3f0(scale/2, 0)),
    	style=Cint(FILLED),
    	color=img.fill,
    	stroke_color=img.stroke,
    	visible=img.visible
    ), img.screen)
end
=#
function Compose.draw{T}(img::GLVisualizeBackend, form::Compose.Form{T})

	if vector_properties_require_push_pop(img)
        for (idx, primitive) in enumerate(form.primitives)
            push_vector_properties(img, idx)
            draw(img, primitive)
            pop_vector_properties(img)
        end
    else
        for (idx, primitive) in enumerate(form.primitives)
            for (propertytype, property) in img.vector_properties
                if isnull(property)
                    continue
                end
                primitives = get(property).primitives
                if idx > length(primitives)
                    error("Vector form and vector property differ in length. Can't distribute.")
                end
                apply_property(img, primitives[idx])
            end
            Compose.draw(img, primitive)
        end
    end
end


function _add_line(points::Vector{Point2f0}, color, thickness)
    c = fill(RGBA{Float32}(color), length(points))
    robj      = visualize(points, :lines, color=c, thickness=thickness)
    _view(robj, camera=:orthographic_pixel)
end
function _add_line(points::LineSegment{Point2f0}, color, thickness)
    robj = visualize([points],
        color     = color,
        thickness = thickness
    )
    _view(robj, camera=:orthographic_pixel)
end
function add_line(points::Vector{Point2f0}, color, thickness)
    N = length(points)
    N <= 1 && return
    if N == 2
        _add_line(LineSegment{Point2f0}(points...), color, thickness)
    elseif N == 3
        error("Not implemented yet")
    else
        _add_line(points, color, thickness)
    end
end
function Compose.draw(img::GLVisualizeBackend, prim::Compose.LinePrimitive)
	N = length(prim.points)
    N <= 1 && return
    points = Point2f0[absolute_native_units(img, p) for p in prim.points]
    add_line(points, img.stroke, absolute_native_units(img, img.linewidth))
end

function Compose.draw(img::GLVisualizeBackend, form::Compose.FormBatch)
    println("FormBatch: ", form)
end

let positions    = 0,
    scales       = 0,
    fillcolors   = 0,
    strokecolors = 0,
    indices      = 0

function Compose.draw(img::GLVisualizeBackend, prim::Compose.RectanglePrimitive)
    wh = relative_native_units(img, (prim.width, prim.height))
    xy = absolute_native_units(img, prim.corner)-Point2f0(0, wh[2])
    stroke_width = img.stroke.alpha > 0 ? 5f0 : 0f0
    fillcolor = img.fill
    stroke_color = img.stroke

        positions = GLBuffer([xy])
        scales    = GLBuffer([wh])
        fillcolors = GLBuffer([fillcolor])
        strokecolors = GLBuffer([stroke_color])
        _view(visualize((RECTANGLE, positions),
        	color=fillcolors,
            scale=scales,
        	stroke_color=strokecolors,
            stroke_width=stroke_width,
        ), img.screen, camera=:orthographic_pixel)

end
end

function Compose.draw(img::GLVisualizeBackend, prim::Compose.PolygonPrimitive)
    warn("PolygonPrimitive NOT IMPLEMENTED YET")
    # NOT SUPPORTED YET
end




function Compose.draw(img::GLVisualizeBackend, prim::Compose.EllipsePrimitive)
	warn("EllipsePrimitive NOT IMPLEMENTED YET")
    # NOT SUPPORTED YET
end


function Compose.draw(img::GLVisualizeBackend, prim::Compose.CurvePrimitive)
	warn("CURVE NOT IMPLEMENTED YET")
    # NOT SUPPORTED YET
end

function Compose.draw(img::GLVisualizeBackend, prim::Compose.BitmapPrimitive)
    xyz = Vec3f0(prim.corner.x.abs, prim.corner.y.abs, 0)
    scale = Vec3f0(prim.width.abs, prim.height.abs, 1)
    _view(visualize(colorim(prim.data), model=translationmatrix(xyz)*scalematrix(scale)), img.screen, camera=:orthographic_pixel)
end

function gen_text(text, atlas, font, position, scale, offset)
    pos = GLVisualize.calc_position(text, position, scale, font, atlas)
    s = Vec2f0[GLVisualize.glyph_scale!(atlas, c, font) .* scale for c in text]
    off = GLVisualize.calc_offset(text, scale, font, atlas) .+ Point2f0(0, offset)
    uvwidth = Vec4f0[GLVisualize.glyph_uv_width!(atlas, c, font) for c in text]
    pos, s, off, uvwidth
end


function pango_parse_markup(text)
    c_stripped_text = Array(Ptr{UInt8}, 1)
    c_attr_list = Array(Ptr{Void}, 1)
    ret = ccall((:pango_parse_markup, Compose.libpango),
        Int32,
        (Ptr{UInt8}, Int32, UInt32, Ptr{Ptr{Void}},
        Ptr{Ptr{UInt8}}, Ptr{UInt32}, Ptr{Void}),
        Compat.String(text), -1, 0, c_attr_list, c_stripped_text,
        C_NULL, C_NULL
    )
    if ret == 0
        error("Could not parse pango markup.")
    end
    str = Compat.String(c_stripped_text[1])

    # TODO: do c_stripped_text and c_attr_list need to be freed?

    return convert(Vector{UInt8}, str), c_attr_list[]
end


function parse_pango(text::AbstractString, scale)
    text, c_attr_list = pango_parse_markup(text)
    GLV = GLVisualize

    atlas          = GLV.get_texture_atlas()
    font           = GLV.defaultfont()

    last_idx = 1
    last_offset = 0.0
    last_scale = Vec2f0(1.0)
    last_position = Point2f0(0)

    positions       = Point2f0[]
    scales          = Vec2f0[]
    offset          = Point2f0[]
    uv_offset_width = Vec4f0[]
    for (idx, attr) in Compose.unpack_pango_attr_list(c_attr_list)
        current_text = Compat.String(text[last_idx:idx])
        last_idx = idx+1

        pos, sa, oa, uvwidth = gen_text(current_text,
            atlas, font, last_position, last_scale.*scale, last_offset
        )
        append!(scales, sa)
        append!(positions, pos)
        append!(offset, oa)
        append!(uv_offset_width, uvwidth)
        last_position = GLVisualize.calc_position(
            last(positions), Point2f0(0), atlas,
            last(current_text), font, last_scale.*scale
        )

        last_offset = 0.0
        if !(attr.rise === nothing)
            last_offset = ((attr.rise / Compose.PANGO_SCALE))
        end
        last_scale = Vec2f0(1)
        if !(attr.scale === nothing)
            last_scale = Vec2f0(attr.scale)
        end
    end
    last_scale = Vec2f0(1)
    if last_idx <= length(text)
        current_text = Compat.String(text[last_idx:end])
        pos, sa, oa, uvwidth = gen_text(current_text,
            atlas, font, last_position, last_scale.*scale, last_offset
        )
        append!(scales, sa)
        append!(positions, pos)
        append!(offset, oa)
        append!(uv_offset_width, uvwidth)
    end
    positions, scales, offset, uv_offset_width
end




function Compose.draw(img::GLVisualizeBackend, prim::Compose.TextPrimitive)
	pos 	= absolute_native_units(img, prim.position)
	s1 		= absolute_native_units(img, img.fontsize)/20f0
	s 		= Vec2f0(s1)
    positions, scales, offset, uv_offset_width = parse_pango(prim.value, s)
    atlas = GLVisualize.get_texture_atlas();
	obj 	= visualize((DISTANCEFIELD, positions),
        distancefield=atlas.images,
        scale=scales,
        offset=offset,
        uv_offset_width=uv_offset_width,
        color=img.fill
    );
	bb 		= value(GLAbstraction.boundingbox(obj))
    w,h,_   = widths(bb)
	x,y,_ 	= minimum(bb)
    pos     -= Point2f0(x, y)
    transmat = eye(Mat{4,4,Float32})
	if prim.rot.theta != 0.0
        pivot = Vec3f0(absolute_native_units(img, prim.rot.offset), 0)
        rot = GLAbstraction.rotationmatrix_z(Float32(-prim.rot.theta))
        transmat *= translationmatrix(pivot)*rot*translationmatrix(-pivot)
    end
    if prim.halign != Compose.hleft || prim.valign != Compose.vbottom
        if prim.halign == Compose.hcenter
            pos = (pos[1] - (w/2f0), pos[2])
        elseif prim.halign == Compose.hright
            pos = (pos[1] - w, pos[2])
        end
        if prim.valign == Compose.vcenter
            pos = (pos[1], pos[2] - h/2f0)
        elseif prim.valign == Compose.vtop
            pos = (pos[1], pos[2] - h)
        end
    end
    transmat *= translationmatrix(Vec3f0(pos..., 0))
	GLAbstraction.transformation(obj, transmat)
	_view(obj, img.screen, camera=:orthographic_pixel)
end






end
