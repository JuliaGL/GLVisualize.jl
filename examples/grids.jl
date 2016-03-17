# using GeometryTypes
# using GLVisualize
# w = glscreen()
# @async renderloop(w)
#
# """
# Returns a tuple of points and indices which can be rendered as line segments.
# You can pass an optional `step` plus `stepscale`, to scale the linesegment at
# every `step` by `stepscale`.
# Example output for `step=3`:
# ```
# .              .
# |    .    .    |
# |____|____|____|
# ```
# """
# function tick_axis{N,T}(dir::Vec{N,T}, tick_dir::Vec{N,T}, range::Range, step=1, stepscale=1.)
#     indices = Array(Cuint, num_points*2)
#     points  = Array(Point{N,T}, num_points)
#     gen_grid!(indices, points, range, step, stepscale)
# end
#
# """
# inplace version of `tick_axis`. Improves speed for e.g. animations
# """
# function tick_axis!{N,T}(
#         points, indices,
#         a::Vec{N,T}, b::Vec{N,T}, tick_dir::Vec{N,T}, step::T, step_long=1, step_long_scale=1.
#     )
#     ab = b-a
#     dir = normalize(ab)*step
#     # generate grid point edges like:
#     # :    :    :    :
#     step_count = floor(Int, norm(ab) / step)
#     if step_count*2 > length(points) # resize if necessary
#         resize!(points, step_count*2)
#         resize!(indices, step_count*4) # we can assume, that indices is wrong as well
#     end
#     current_position, i = a, 1
#     @inbounds for k=1:step_count
#         current_position = dir*i
#         points[i] = current_position
#         scaling = ((k-1)%step_long==0) ? step_long_scale : 1.
#         points[i+1] = current_position+(tick_dir*scaling)
#         i+=2
#     end
#     # connect the edges
#     # .    .    .    .
#     #|____|____|____|
#     i = 1
#     @inbounds for base_index=0:2:(length(points)-1)
#         # connect tick_dir
#         indices[i  ] = base_index
#         indices[i+1] = base_index+1
#         # connect to next segment
#         indices[i+2] = base_index
#         indices[i+3] = base_index+2
#         i+=4
#     end
#     points, indices
# end
#
#
# immutable Glyph{N,T,C<:Colorant}
#     position::Point{N,T}
#     scale::Vec{2,T}
#     uv_width::Vec{4,T}
#     offset::Vec{2,T}
#     rotation::Vec{N,T}
#     color::C
# end
#
#
# type TextBuffer
#     text::ArrayOfStructs{Glyph{N,T}}
#     atlas
# end
# length(t::TextBuffer) = length(t.text)
# setindex!(t::TextBuffer, value::Glyph, index) = t.text[index] = value
# function setindex!(t::TextBuffer, value::Tuple, index)
#     char, font, position, scale = value
#     t.text[index] = Glyph(
#         position,
#         scale,
#         get_uv_offsetwidth!(t.atlas, char, font),
#         get_scale!(t.atlas, char, font, scale),
#         glyph_bearing!(t.atlas, char, font, scale)
#     )
# end
# function splice!(text::TextBuffer, to_insert::TextTypes, start_index=1)
#     len = offset+length(to_insert)
#     if len <= length(text)
#         resize!(text, len)
#     end
#     i = start_index
#     for char in to_insert
#         text[i] = (char, font, position, scale)
#         position = calc_position(position, start_pos, atlas, char, font, scale)
#         i+=1
#     end
#     positions, uvs, scales
# end
#
# function tick_labels(t_start::Vec{N,T}, t_end::Vec{N,T}, tick_dir::Vec{N,T}, step::T, long_step=5, precision)
#     # do text only for long step
#     step_count = floor(Int, (b-a) / step / long_step)
#     positions = Point{N,T}[]
#     sizehint!(positions, step_count*precision) # should be roughly that many digitis, but can't say for sure
#     tick = a
#     for k=1:step_count
#         tick += step*long_step
#         str = Showoff.format_fixed_scientific(tick, precision, false)
#         for char in str
#
#
#
#
# end
#
# points, indices = gen_grid(Vec3f0(0,0,1), Vec3f0(0,0.1,0), linspace(0f0,3f0, 20), 5, 1.5)
# empty!(w.renderlist)
# view(visualize(points, :linesegment, indices=indices), camera=:perspective)
# map(Int, indices)
