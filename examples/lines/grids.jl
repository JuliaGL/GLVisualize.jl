using GeometryTypes
using GLVisualize, Colors, GLWindow
w = glscreen()
@async renderloop(w)
N = 1000
view(visualize(
    randstring(N),
    scale=fill(Vec2f0(0.1), N),
    color=fill(RGBA{Float32}(0,0,0,1), N),
    rotation=fill(Vec3f0(0,0,1), N),
    position=fill(Point3f0(0), N),
), camera=:perspective)


richtext = GLVisualize.RichText(GLVisualize.Text(renderlist(w)[1]))
"""
Returns a tuple of points and indices which can be rendered as line segments.
You can pass an optional `step` plus `stepscale`, to scale the linesegment at
every `step` by `stepscale`.
Example output for `step=3`:
```
.              .
|    .    .    |
|____|____|____|
```
"""
function tick_axis{N,T}(a::Point{N,T}, b::Point{N,T}, tick_dir::Vec{N,T}, step, step_long=1, step_long_scale=1.)
    indices = Cuint[]
    points  = Point{N,T}[]
    tick_axis!(points, indices, a, b, tick_dir, step, step_long, step_long_scale)
end

"""
inplace version of `tick_axis`. Improves speed for e.g. animations
"""
function tick_axis!{N,T}(
        points, indices,
        a::Point{N,T}, b::Point{N,T}, tick_dir::Vec{N,T}, step, step_long=1, step_long_scale=1.
    )
    ab = Vec{N,T}(b-a)
    len = norm(ab)
    dir = (ab/len)*step
    # generate grid point edges like:
    # :    :    :    : (.) <- optional ending point
    step_count_high = ceil(Int, len / step)+1
    step_count_low = floor(Int, len / step)+1
    endpoint = step_count_high-step_count_low #0 or 1
    if step_count_high*2 > length(points) # resize if necessary
        resize!(points, step_count_low*2+endpoint)
        resize!(indices, step_count_low*4+(endpoint*2)) # we can assume, that indices are wrong as well
    end
    points[end] = b # insert end point
    if endpoint==0
        indices[end], indices[end-1] = length(points)-2, length(points)-1# 0 indexed endpoint
    end
    current_position, k = a, 0
    for i=1:2:(step_count_low*2)
        current_position = Vec{N,T}(a)+(dir*k)
        points[i] = current_position
        scaling = (k%step_long==0) ? step_long_scale : 1.
        points[i+1] = current_position+(tick_dir*scaling)
        k+=1
    end
    # connect the edges
    # .    .    .    .
    #|____|____|____|
    i, base_index = 1, 0
    for count=1:(step_count_high-1)
        # connect tick_dir
        indices[i  ] = base_index
        indices[i+1] = base_index+1
        # connect to next segment
        indices[i+2] = base_index
        indices[i+3] = base_index+2
        i+=4;base_index+=2
    end
    points, indices
end

function annoteded_axis(range, axis, tick_dir, richtext, origin)
    s = step(range)
    step_long=5; step_long_scale=1.2
    b = origin+normalize(axis)*last(range)
    points, indices = tick_axis(Point3f0(origin), Point3f0(b), tick_dir, s, step_long, step_long_scale)
    for ri in 1:step_long:length(range)
        p = points[(ri-1)*2+1]
        x = string(range[ri])
        insert!(richtext, x, richtext.cursor, Dict(
            :position => Point3f0[p+Point3f0(0,i*0.1,0) for i=0:(length(x)-1)],
        ))
        richtext.cursor += length(x)
    end
    view(visualize(points, :linesegment, indices=indices), camera=:perspective)
end
function grid_axis(cube, richtext)
    o = origin(cube)
    w = widths(cube)
    m = o+(w*0.5f0)
    xdir = w .* unit(Point3f0, 1)
    zdir = xdir+w .* unit(Point3f0, 2)
    x = o+xdir
    z = o+zdir
    origins = [x, z, x]
    for i=1:3
        range = linspace(o[i], w[i], 20)
        o2 = origins[i]
        tick_dir = normalize(o2-m) * -0.05f0
        annoteded_axis(range, unit(Point3f0, i), tick_dir, richtext, o2)
    end
end
grid_axis(AABB{Float32}(Vec3f0(0), Vec3f0(1)), richtext)

richtext.cursor
x = "hey duude"

insert!(richtext, x, 0:1, Dict(
    :position => Point3f0[Point3f0(0,i*0.8,0) for i=0:(length(x)-1)],
    :scale => Vec2f0(0.05),
    :rotation => Vec3f0(pi,0,4*pi)
))
richtext.text.scales[1:end] = fill(Vec2f0(0), length(richtext))
# #
# #
# # immutable Glyph{N,T,C<:Colorant}
# #     position::Point{N,T}
# #     scale::Vec{2,T}
# #     uv_width::Vec{4,T}
# #     offset::Vec{2,T}
# #     rotation::Vec{N,T}
# #     color::C
# # end
# #
# #
# # type TextBuffer
# #     text::ArrayOfStructs{Glyph{N,T}}
# #     atlas
# # end
# # length(t::TextBuffer) = length(t.text)
# # setindex!(t::TextBuffer, value::Glyph, index) = t.text[index] = value
# # function setindex!(t::TextBuffer, value::Tuple, index)
# #     char, font, position, scale = value
# #     t.text[index] = Glyph(
# #         position,
# #         scale,
# #         get_uv_offsetwidth!(t.atlas, char, font),
# #         get_scale!(t.atlas, char, font, scale),
# #         glyph_bearing!(t.atlas, char, font, scale)
# #     )
# # end
# # function splice!(text::TextBuffer, to_insert::TextTypes, start_index=1)
# #     len = offset+length(to_insert)
# #     if len <= length(text)
# #         resize!(text, len)
# #     end
# #     i = start_index
# #     for char in to_insert
# #         text[i] = (char, font, position, scale)
# #         position = calc_position(position, start_pos, atlas, char, font, scale)
# #         i+=1
# #     end
# #     positions, uvs, scales
# # end
# #
# # function tick_labels(t_start::Vec{N,T}, t_end::Vec{N,T}, tick_dir::Vec{N,T}, step::T, long_step=5, precision)
# #     # do text only for long step
# #     step_count = floor(Int, (b-a) / step / long_step)
# #     positions = Point{N,T}[]
# #     sizehint!(positions, step_count*precision) # should be roughly that many digitis, but can't say for sure
# #     tick = a
# #     for k=1:step_count
# #         tick += step*long_step
# #         str = Showoff.format_fixed_scientific(tick, precision, false)
# #         for char in str
# #
# #
# #
# #
# # end
# #
# # points, indices = gen_grid(Vec3f0(0,0,1), Vec3f0(0,0.1,0), linspace(0f0,3f0, 20), 5, 1.5)
# # empty!(w.renderlist)
# # view(visualize(points, :linesegment, indices=indices), camera=:perspective)
# # map(Int, indices)
