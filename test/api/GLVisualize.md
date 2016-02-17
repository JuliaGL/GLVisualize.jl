# GLVisualize

## Exported

---

<a id="method__clicked.1" class="lexicon_definition"></a>
#### clicked(robj::GLAbstraction.RenderObject,  button::GLAbstraction.MouseButton,  window::GLWindow.Screen) [¶](#method__clicked.1)
Returns two signals, one boolean signal if clicked over `robj` and another
one that consists of the object clicked on and another argument indicating that it's the first click


*source:*
[GLVisualize/src/utils.jl:62](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/utils.jl#L62)

---

<a id="method__cubecamera.1" class="lexicon_definition"></a>
#### cubecamera(window) [¶](#method__cubecamera.1)
Creates a camera which is steered by a cube for `window`.


*source:*
[GLVisualize/src/camera.jl:97](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/camera.jl#L97)

---

<a id="method__dragged_on.1" class="lexicon_definition"></a>
#### dragged_on(robj::GLAbstraction.RenderObject,  button::GLAbstraction.MouseButton,  window::GLWindow.Screen) [¶](#method__dragged_on.1)
Returns a signal with the difference from dragstart and current mouse position,
and the index from the current ROBJ id.


*source:*
[GLVisualize/src/utils.jl:95](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/utils.jl#L95)

---

<a id="method__is_hovering.1" class="lexicon_definition"></a>
#### is_hovering(robj::GLAbstraction.RenderObject,  window::GLWindow.Screen) [¶](#method__is_hovering.1)
Returns a boolean signal indicating if the mouse hovers over `robj`


*source:*
[GLVisualize/src/utils.jl:76](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/utils.jl#L76)

---

<a id="method__visualize.1" class="lexicon_definition"></a>
#### visualize(main) [¶](#method__visualize.1)
Creates a default visualization for any value.
The defaults can be customized via the key word arguments and the style parameter.
The style can change the the look completely (e.g points displayed as lines, or particles),
while the key word arguments just alter the parameters of one visualization.
Always returns a context, which can be displayed on a window via view(::Context, [display]).


*source:*
[GLVisualize/src/visualize_interface.jl:17](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize_interface.jl#L17)

---

<a id="method__visualize.2" class="lexicon_definition"></a>
#### visualize(main,  s::Symbol) [¶](#method__visualize.2)
Creates a default visualization for any value.
The defaults can be customized via the key word arguments and the style parameter.
The style can change the the look completely (e.g points displayed as lines, or particles),
while the key word arguments just alter the parameters of one visualization.
Always returns a context, which can be displayed on a window via view(::Context, [display]).


*source:*
[GLVisualize/src/visualize_interface.jl:17](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize_interface.jl#L17)

## Internal

---

<a id="method___default.1" class="lexicon_definition"></a>
#### _default{G<:GeometryTypes.GeometryPrimitive{N, T}}(geometry::Union{G<:GeometryTypes.GeometryPrimitive{N, T}, Reactive.Signal{G<:GeometryTypes.GeometryPrimitive{N, T}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.1)
We plot simple Geometric primitives as particles with length one.
At some point, this should all be appended to the same particle system to increase
performance.


*source:*
[GLVisualize/src/visualize/particles.jl:25](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L25)

---

<a id="method___default.2" class="lexicon_definition"></a>
#### _default{N, T}(main::Union{Array{FixedSizeArrays.Point{N, T}, 1}, GLAbstraction.GPUArray{FixedSizeArrays.Point{N, T}, 1}, Reactive.Signal{Array{FixedSizeArrays.Point{N, T}, 1}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.2)
Vectors of n-dimensional points get ndimensional rectangles as default
primitives. (Particles)


*source:*
[GLVisualize/src/visualize/particles.jl:48](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L48)

---

<a id="method___default.3" class="lexicon_definition"></a>
#### _default{P<:GeometryTypes.AbstractGeometry{N, T}, T<:AbstractFloat, N}(main::Tuple{P<:GeometryTypes.AbstractGeometry{N, T}, Union{Array{T<:AbstractFloat, N}, GLAbstraction.GPUArray{T<:AbstractFloat, N}, Reactive.Signal{Array{T<:AbstractFloat, N}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.3)
arrays of floats with any geometry primitive, will be spaced out on a grid defined
by `ranges` and will use the floating points as the
height for the primitives (`scale_z`)


*source:*
[GLVisualize/src/visualize/particles.jl:111](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L111)

---

<a id="method___default.4" class="lexicon_definition"></a>
#### _default{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, T<:AbstractFloat, N}(main::Tuple{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, Union{Array{T<:AbstractFloat, N}, GLAbstraction.GPUArray{T<:AbstractFloat, N}, Reactive.Signal{Array{T<:AbstractFloat, N}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.4)
arrays of floats with the sprite primitive type (2D geometry + picture like),
will be spaced out on a grid defined
by `ranges` and will use the floating points as the
z position for the primitives.


*source:*
[GLVisualize/src/visualize/particles.jl:138](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L138)

---

<a id="method___default.5" class="lexicon_definition"></a>
#### _default{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, T<:AbstractFloat}(main::Tuple{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, Union{Array{T<:AbstractFloat, 1}, GLAbstraction.GPUArray{T<:AbstractFloat, 1}, Reactive.Signal{Array{T<:AbstractFloat, 1}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.5)
Sprites primitives with a vector of floats are treated as something barplot like


*source:*
[GLVisualize/src/visualize/particles.jl:159](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L159)

---

<a id="method___default.6" class="lexicon_definition"></a>
#### _default{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{N, T}}, T<:FixedSizeArrays.Vec{N, T}, N}(main::Tuple{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{N, T}}, Union{Array{T<:FixedSizeArrays.Vec{N, T}, N}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N, T}, N}, Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N, T}, N}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.6)
Vectors with `Vec` as element type are treated as vectors of rotations.
The position is assumed to be implicitely on the grid the vector defines (1D,2D,3D grid)


*source:*
[GLVisualize/src/visualize/particles.jl:71](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L71)

---

<a id="method___default.7" class="lexicon_definition"></a>
#### _default{S<:AbstractString}(main::Union{Reactive.Signal{S<:AbstractString}, S<:AbstractString},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.7)
Transforms text into a particle system of sprites, by inferring the
texture coordinates in the texture atlas, widths and positions of the characters.


*source:*
[GLVisualize/src/visualize/particles.jl:341](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L341)

---

<a id="method___default.8" class="lexicon_definition"></a>
#### _default{T<:AbstractFloat}(main::Union{Array{T<:AbstractFloat, 1}, GLAbstraction.GPUArray{T<:AbstractFloat, 1}, Reactive.Signal{Array{T<:AbstractFloat, 1}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.8)
Vectors of floats are treated as barplots, so they get a HyperRectangle as
default primitive.


*source:*
[GLVisualize/src/visualize/particles.jl:35](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L35)

---

<a id="method___default.9" class="lexicon_definition"></a>
#### _default{T<:AbstractFloat}(main::Union{Array{T<:AbstractFloat, 2}, GLAbstraction.GPUArray{T<:AbstractFloat, 2}, Reactive.Signal{Array{T<:AbstractFloat, 2}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.9)
Matrices of floats are represented as 3D barplots with cubes as primitive


*source:*
[GLVisualize/src/visualize/particles.jl:41](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L41)

---

<a id="method___default.10" class="lexicon_definition"></a>
#### _default{T<:FixedSizeArrays.Point{N, T}}(position::Union{Array{T<:FixedSizeArrays.Point{N, T}, 1}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Point{N, T}, 1}, Reactive.Signal{Array{T<:FixedSizeArrays.Point{N, T}, 1}}},  s::GLAbstraction.Style{:speed},  data::Dict{K, V}) [¶](#method___default.10)
This is the most primitive particle system, which uses simple points as primitives.
This is supposed to be very fast!


*source:*
[GLVisualize/src/visualize/particles.jl:237](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L237)

---

<a id="method___default.11" class="lexicon_definition"></a>
#### _default{T<:FixedSizeArrays.Vec{N, T}}(main::Union{Array{T<:FixedSizeArrays.Vec{N, T}, 2}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N, T}, 2}, Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N, T}, 2}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.11)
2D matrices of vectors are 2D vector field with a an unicode arrow as the default
primitive.


*source:*
[GLVisualize/src/visualize/particles.jl:63](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L63)

---

<a id="method___default.12" class="lexicon_definition"></a>
#### _default{T<:FixedSizeArrays.Vec{N, T}}(main::Union{Array{T<:FixedSizeArrays.Vec{N, T}, 3}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N, T}, 3}, Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N, T}, 3}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V}) [¶](#method___default.12)
3D matrices of vectors are 3D vector field with a pyramid (arrow) like default
primitive.


*source:*
[GLVisualize/src/visualize/particles.jl:56](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L56)

---

<a id="method__call.1" class="lexicon_definition"></a>
#### call{T, N}(::Type{GLVisualize.Grid{N, T<:Range{T}}},  a::AbstractArray{T, N},  ranges::Tuple) [¶](#method__call.1)
This constructor constructs a grid from ranges given as a tuple.
Due to the approach, the tuple `ranges` can consist of NTuple(2, T)
and all kind of range types. The constructor will make sure that all ranges match
the size of the dimension of the array `a`.


*source:*
[GLVisualize/src/types.jl:28](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/types.jl#L28)

---

<a id="method__meshparticle.1" class="lexicon_definition"></a>
#### meshparticle(p,  s,  data) [¶](#method__meshparticle.1)
This is the main function to assemble particles with a GLNormalMesh as a primitive


*source:*
[GLVisualize/src/visualize/particles.jl:194](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L194)

---

<a id="method__projection_switch.1" class="lexicon_definition"></a>
#### projection_switch(width,  mousehover,  mouse_buttons_pressed) [¶](#method__projection_switch.1)
creates a button that can switch between orthographic and perspective projection


*source:*
[GLVisualize/src/camera.jl:47](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/camera.jl#L47)

---

<a id="method__sprites.1" class="lexicon_definition"></a>
#### sprites(p,  s,  data) [¶](#method__sprites.1)
Main assemble functions for sprite particles.
Sprites are anything like distance fields, images and simple geometries


*source:*
[GLVisualize/src/visualize/particles.jl:287](https://github.com/JuliaGL/GLVisualize.jl/tree/84058ced4c62829a779b48e10072a4e7e2d780b2/src/visualize/particles.jl#L287)

