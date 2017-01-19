"""
Determines if of Image Type
"""
function isa_image{T<:Matrix}(x::Type{T})
    eltype(T) <: Union{Colorant, AbstractFloat}
end
isa_image(x::Matrix) = isa_image(typeof(x))
isa_image(x::Images.Image) = true
isa_image(x) = false

# Splits a dictionary in two dicts, via a condition
function Base.split(condition::Function, associative::Associative)
    A = similar(associative)
    B = similar(associative)
    for (key, value) in associative
        if condition(key, value)
            A[key] = value
        else
            B[key] = value
        end
    end
    A, B
end


function assemble_robj(data, program, bb, primitive, pre_fun, post_fun)
    pre = if pre_fun != nothing
        () -> (GLAbstraction.StandardPrerender(); pre_fun())
    else
        GLAbstraction.StandardPrerender()
    end
    robj = RenderObject(data, program, pre, nothing, bb, nothing)
    post = if haskey(data, :instances)
        GLAbstraction.StandardPostrenderInstanced(data[:instances], robj.vertexarray, primitive)
    else
        GLAbstraction.StandardPostrender(robj.vertexarray, primitive)
    end
    robj.postrenderfunction = if post_fun != nothing
        () -> begin
            post()
            post_fun()
        end
    else
        post
    end
    robj
end


function assemble_shader(data)
    shader = data[:shader]
    delete!(data, :shader)
    default_bb = Signal(centered(AABB))
    bb  = get(data, :boundingbox, default_bb)
    if bb == nothing || isa(bb, Signal{Void})
        bb = default_bb
    end
    glp = get(data, :gl_primitive, GL_TRIANGLES)
    robj = assemble_robj(
        data, shader, bb, glp,
        get(data, :prerender, nothing),
        get(data, :postrender, nothing)
    )
    Context(robj)
end




function y_partition_abs(area, amount)
    a = round(Int, amount)
    p = const_lift(area) do r
        (
            SimpleRectangle{Int}(0, 0, r.w, a),
            SimpleRectangle{Int}(0, a, r.w, r.h - a)
        )
    end
    return map(first, p), map(last, p)
end
function x_partition_abs(area, amount)
    a = round(Int, amount)
    p = const_lift(area) do r
        (
            SimpleRectangle{Int}(0, 0, a, r.h),
            SimpleRectangle{Int}(a, 0, r.w - a, r.h)
        )
    end
    return map(first, p), map(last, p)
end

function y_partition(area, percent)
    amount = percent / 100.0
    p = const_lift(area) do r
        (
            SimpleRectangle{Int}(0, 0, r.w, round(Int, r.h*amount)),
            SimpleRectangle{Int}(0, round(Int, r.h*amount), r.w, round(Int, r.h*(1-amount)))
        )
    end
    return map(first, p), map(last, p)
end
function x_partition(area, percent)
    amount = percent / 100.0
    p = const_lift(area) do r
        (
            SimpleRectangle{Int}(0, 0, round(Int, r.w*amount), r.h ),
            SimpleRectangle{Int}(round(Int, r.w*amount), 0, round(Int, r.w*(1-amount)), r.h)
        )
    end
    return map(first, p), map(last, p)
end


glboundingbox(mini, maxi) = AABB{Float32}(Vec3f0(mini), Vec3f0(maxi)-Vec3f0(mini))
function default_boundingbox(main, model)
    main == nothing && return Signal(AABB{Float32}(Vec3f0(0), Vec3f0(1)))
    const_lift(*, model, AABB{Float32}(main))
end
@compat (::Type{AABB})(a::GPUArray) = AABB{Float32}(gpu_data(a))
@compat (::Type{AABB{T}}){T}(a::GPUArray) = AABB{T}(gpu_data(a))


"""
Returns two signals, one boolean signal if clicked over `robj` and another
one that consists of the object clicked on and another argument indicating that it's the first click
"""
function clicked(robj::RenderObject, button::MouseButton, window::Screen)
    @materialize mouse_hover, mouse_buttons_pressed = window.inputs
    leftclicked = const_lift(mouse_hover, mouse_buttons_pressed) do mh, mbp
        mh[1] == robj.id && mbp == Int[button]
    end
    clicked_on_obj = keepwhen(leftclicked, false, leftclicked)
    clicked_on_obj = const_lift((mh, x)->(x,robj,mh), mouse_hover, leftclicked)
    leftclicked, clicked_on_obj
end

"""
Returns a boolean signal indicating if the mouse hovers over `robj`
"""
is_hovering(robj::RenderObject, window::Screen) =
    droprepeats(const_lift(is_same_id, mouse2id(window), robj))

function dragon_tmp(past, mh, mbp, mpos, robj, button, start_value)
    diff, dragstart_index, was_clicked, dragstart_pos = past
    over_obj = mh[1] == robj.id
    is_clicked = mbp == Int[button]
    if is_clicked && was_clicked # is draggin'
        return (dragstart_pos-mpos, dragstart_index, true, dragstart_pos)
    elseif over_obj && is_clicked && !was_clicked # drag started
        return (Vec2f0(0), mh[2], true, mpos)
    end
    return start_value
end

"""
Returns a signal with the difference from dragstart and current mouse position,
and the index from the current ROBJ id.
"""
function dragged_on(robj::RenderObject, button::MouseButton, window::Screen)
    @materialize mouse_buttons_pressed, mouseposition = window.inputs
    mousehover = mouse2id(window)
    mousedown = const_lift(GLAbstraction.singlepressed, mouse_buttons_pressed, GLFW.MOUSE_BUTTON_LEFT)
    condition = const_lift(is_same_id, mousehover, robj)
    dragg = GLAbstraction.dragged(mouseposition, mousedown, condition)
    filterwhen(mousedown, (value(dragg), 0), map(dragg) do d
        d, value(mousehover).index
    end)
end

points2f0{T}(positions::Vector{T}, range::Range) = Point2f0[Point2f0(range[i], positions[i]) for i=1:length(range)]

extrema2f0{T<:Intensity,N}(x::Array{T,N}) = Vec2f0(extrema(reinterpret(Float32,x)))
extrema2f0{T,N}(x::Array{T,N}) = Vec2f0(extrema(x))
extrema2f0(x::GPUArray) = extrema2f0(gpu_data(x))
function extrema2f0{T<:Vec,N}(x::Array{T,N})
    _norm = map(norm, x)
    Vec2f0(minimum(_norm), maximum(_norm))
end


"""
Converts index arrays to the OpenGL equivalent.
"""
to_indices(x::GLBuffer) = x
to_indices(x::TOrSignal{Int}) = x
to_indices(x::VecOrSignal{UnitRange{Int}}) = x
"""
For integers, we transform it to 0 based indices
"""
to_indices{I<:Integer}(x::Vector{I}) = indexbuffer(map(i-> Cuint(i-1), x))
function to_indices{I<:Integer}(x::Signal{Vector{I}})
    x = map(x-> Cuint[i-1 for i=x], x)
    gpu_mem = GLBuffer(value(x), buffertype = GL_ELEMENT_ARRAY_BUFFER)
    preserve(const_lift(update!, gpu_mem, x))
    gpu_mem
end
"""
If already GLuint, we assume its 0 based (bad heuristic, should better be solved with some Index type)
"""
to_indices{I<:GLuint}(x::Vector{I}) = indexbuffer(x)
function to_indices{I<:GLuint}(x::Signal{Vector{I}})
    gpu_mem = GLBuffer(value(x), buffertype = GL_ELEMENT_ARRAY_BUFFER)
    preserve(const_lift(update!, gpu_mem, x))
    gpu_mem
end
to_indices(x) = error(
    "Not a valid index type: $x.
    Please choose from Int, Vector{UnitRange{Int}}, Vector{Int} or a signal of either of them"
)




function mix_linearly{C<:Colorant}(a::C, b::C, s)
    RGBA{Float32}((1-s)*comp1(a)+s*comp1(b), (1-s)*comp2(a)+s*comp2(b), (1-s)*comp3(a)+s*comp3(b), (1-s)*alpha(a)+s*alpha(b))
end

color_lookup(cmap, value, mi, ma) = color_lookup(cmap, value, (mi, ma))
function color_lookup(cmap, value, color_norm)
    mi,ma = color_norm
    scaled = clamp((value-mi)/(ma-mi), 0, 1)
    index = scaled * (length(cmap)-1)
    i_a, i_b = floor(Int, index)+1, ceil(Int, index)+1
    mix_linearly(cmap[i_a], cmap[i_b], scaled)
end


"""
Creates a moving average and discards values to close together.
If discarded return (false, p), if smoothed, (true, smoothed_p).
"""
function moving_average(p, cutoff,  history, n = 5)
    if length(history) > 0
        if norm(p - history[end]) < cutoff
            return false, p # don't keep point
        end
    end
    if length(history) == 5
        # maybe better to just keep a current index
        history[1:5] = circshift(view(history, 1:5), -1)
        history[end] = p
    else
        push!(history, p)
    end
    true, sum(history) ./ length(history)# smooth
end

function layoutlinspace(n::Integer)
    if n == 1
        1:1
    else
        linspace(1/n, 1, n)
    end
end
xlayout(x::Int) = zip(layoutlinspace(x), Iterators.repeated(""))
function xlayout{T <: AbstractFloat}(x::AbstractVector{T})
    zip(x, Iterators.repeated(""))
end

function xlayout{T <: AbstractString}(x::AbstractVector{T})
    zip(layoutlinspace(length(x)), x)
end
function ylayout(x::AbstractVector)
    zip(layoutlinspace(length(x)), x)
end
function IRect(x, y , w, h)
    SimpleRectangle(
        round(Int, x),
        round(Int, y),
        round(Int, w),
        round(Int, h),
    )
end

function laytout_rect(area, lastw, lasth, w, h)
    wp = widths(area)
    xmin = wp[1] * lastw
    ymin = wp[2] * lasth
    xmax = wp[1] * w
    ymax = wp[2] * h
    xmax = max(xmin, xmax)
    xmin = min(xmin, xmax)
    ymax = max(ymin, ymax)
    ymin = min(ymin, ymax)
    IRect(xmin, ymin, xmax - xmin, ymax - ymin)
end

function layoutscreens(parent, layout; kw_args...)
    reverse!(layout) # we start from bottom to top, while lists are written top to bottom
    lastw, lasth = 0, 0
    result = Vector{Screen}[]
    for (h, xlist) in ylayout(layout)
        result_x = Screen[]
        for (w, title) in xlayout(xlist)
            area = const_lift(laytout_rect, parent.area, lastw, lasth, w, h)
            lastw = w
            screen = Screen(parent; area = area, kw_args...)
            push!(result_x, screen)
            if !isempty(title)
                #title_screen = Screen(screen, )
            end
        end
        lastw = 0; lasth = h
        push!(result, result_x)
    end
    result
end
