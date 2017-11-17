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
# function tick_axis{N,T}(a::Point{N,T}, b::Point{N,T}, tick_dir::Vec{N,T}, step, step_long=1, step_long_scale=1.)
#     indices = Cuint[]
#     points  = Point{N,T}[]
#     tick_axis!(points, indices, a, b, tick_dir, step, step_long, step_long_scale)
# end
#
# """
# inplace version of `tick_axis`. Improves speed for e.g. animations
# """
# function tick_axis!{N,T}(
#         points, indices,
#         a::Point{N,T}, b::Point{N,T}, tick_dir::Vec{N,T}, step, step_long=1, step_long_scale=1.
#     )
#     ab = Vec{N,T}(b-a)
#     len = norm(ab)
#     dir = (ab/len)*step
#     # generate grid point edges like:
#     # :    :    :    : (.) <- optional ending point
#     step_count_high = ceil(Int, len / step)
#     step_count_low = floor(Int, len / step)
#     if step_count_high*2 > length(points) # resize if necessary
#         endpoint = step_count_high-step_count_low #0 or 1
#         resize!(points, step_count_high*2+endpoint)
#         resize!(indices, step_count_high*4+endpoint) # we can assume, that indices are wrong as well
#     end
#     points[end] = b # insert end point
#     indices[end] = length(points)-1 # 0 indexed endpoint
#     current_position, i = a, 1
#     @inbounds for k=0:(step_count_low-1)
#         current_position = Vec{N,T}(a)+(dir*k)
#         points[i] = current_position
#         scaling = (k%step_long==0) ? step_long_scale : 1.
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
# origin = Point3f0(0)
# empty!(w)
#
# points1, indices1 = tick_axis(origin, Point3f0(0,0,1), Vec3f0(-0.1,0,0), 0.1f0, 5, 1.5)
# points2, indices2 = tick_axis(origin, Point3f0(0,1,0), Vec3f0(-0.1,0,0), 0.1f0, 5, 1.5)
# points3, indices3 = tick_axis(origin, Point3f0(1,0,0), Vec3f0(0,-0.1,0), 0.1f0, 5, 1.5)
# _view(visualize(points1, :linesegment, indices=indices1), camera=:perspective)
# _view(visualize(points2, :linesegment, indices=indices2), camera=:perspective)
# _view(visualize(points3, :linesegment, indices=indices3), camera=:perspective)
# _view(visualize(rand(Float32, 32, 32)), camera=:perspective)
# versioninfo()
# using GeometryTypes
#
# lambda = @code_typed blinnphong(Vec3f0(0), Vec3f0(0), Vec3f0(0),Vec3f0(0))
# lambda2 = @code_lowered(blinnphong(Vec3f0(0), Vec3f0(0), Vec3f0(0),Vec3f0(0)))[1]
# for elem in lambda2.args[3].args
#     println(elem)
# end
# a = lambda[1]
# args = a.args
# for elem in args[3].args
#     if isa(elem, Expr) && elem.head == :(=)
#         println(typeof(elem.args[1]))
#     end
# end
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
# # _view(visualize(points, :linesegment, indices=indices), camera=:perspective)
# # map(Int, indices)
