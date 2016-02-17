# API-INDEX


## MODULE: GLVisualize

---

## Methods [Exported]

[clicked(robj::GLAbstraction.RenderObject,  button::GLAbstraction.MouseButton,  window::GLWindow.Screen)](GLVisualize.md#method__clicked.1)  Returns two signals, one boolean signal if clicked over `robj` and another

[cubecamera(window)](GLVisualize.md#method__cubecamera.1)  Creates a camera which is steered by a cube for `window`.

[dragged_on(robj::GLAbstraction.RenderObject,  button::GLAbstraction.MouseButton,  window::GLWindow.Screen)](GLVisualize.md#method__dragged_on.1)  Returns a signal with the difference from dragstart and current mouse position,

[is_hovering(robj::GLAbstraction.RenderObject,  window::GLWindow.Screen)](GLVisualize.md#method__is_hovering.1)  Returns a boolean signal indicating if the mouse hovers over `robj`

[visualize(main)](GLVisualize.md#method__visualize.1)  Creates a default visualization for any value.

[visualize(main,  s::Symbol)](GLVisualize.md#method__visualize.2)  Creates a default visualization for any value.

---

## Methods [Internal]

[_default{G<:GeometryTypes.GeometryPrimitive{N, T}}(geometry::Union{G<:GeometryTypes.GeometryPrimitive{N, T}, Reactive.Signal{G<:GeometryTypes.GeometryPrimitive{N, T}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.1)  We plot simple Geometric primitives as particles with length one.

[_default{N, T}(main::Union{Array{FixedSizeArrays.Point{N, T}, 1}, GLAbstraction.GPUArray{FixedSizeArrays.Point{N, T}, 1}, Reactive.Signal{Array{FixedSizeArrays.Point{N, T}, 1}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.2)  Vectors of n-dimensional points get ndimensional rectangles as default

[_default{P<:GeometryTypes.AbstractGeometry{N, T}, T<:AbstractFloat, N}(main::Tuple{P<:GeometryTypes.AbstractGeometry{N, T}, Union{Array{T<:AbstractFloat, N}, GLAbstraction.GPUArray{T<:AbstractFloat, N}, Reactive.Signal{Array{T<:AbstractFloat, N}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.3)  arrays of floats with any geometry primitive, will be spaced out on a grid defined

[_default{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, T<:AbstractFloat, N}(main::Tuple{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, Union{Array{T<:AbstractFloat, N}, GLAbstraction.GPUArray{T<:AbstractFloat, N}, Reactive.Signal{Array{T<:AbstractFloat, N}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.4)  arrays of floats with the sprite primitive type (2D geometry + picture like),

[_default{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, T<:AbstractFloat}(main::Tuple{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{2, T}, Type{T}}, Union{Array{T<:AbstractFloat, 1}, GLAbstraction.GPUArray{T<:AbstractFloat, 1}, Reactive.Signal{Array{T<:AbstractFloat, 1}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.5)  Sprites primitives with a vector of floats are treated as something barplot like

[_default{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{N, T}}, T<:FixedSizeArrays.Vec{N, T}, N}(main::Tuple{P<:Union{Char, GLVisualize.Shape, GeometryTypes.AbstractGeometry{N, T}}, Union{Array{T<:FixedSizeArrays.Vec{N, T}, N}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N, T}, N}, Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N, T}, N}}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.6)  Vectors with `Vec` as element type are treated as vectors of rotations.

[_default{S<:AbstractString}(main::Union{Reactive.Signal{S<:AbstractString}, S<:AbstractString},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.7)  Transforms text into a particle system of sprites, by inferring the

[_default{T<:AbstractFloat}(main::Union{Array{T<:AbstractFloat, 1}, GLAbstraction.GPUArray{T<:AbstractFloat, 1}, Reactive.Signal{Array{T<:AbstractFloat, 1}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.8)  Vectors of floats are treated as barplots, so they get a HyperRectangle as

[_default{T<:AbstractFloat}(main::Union{Array{T<:AbstractFloat, 2}, GLAbstraction.GPUArray{T<:AbstractFloat, 2}, Reactive.Signal{Array{T<:AbstractFloat, 2}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.9)  Matrices of floats are represented as 3D barplots with cubes as primitive

[_default{T<:FixedSizeArrays.Point{N, T}}(position::Union{Array{T<:FixedSizeArrays.Point{N, T}, 1}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Point{N, T}, 1}, Reactive.Signal{Array{T<:FixedSizeArrays.Point{N, T}, 1}}},  s::GLAbstraction.Style{:speed},  data::Dict{K, V})](GLVisualize.md#method___default.10)  This is the most primitive particle system, which uses simple points as primitives.

[_default{T<:FixedSizeArrays.Vec{N, T}}(main::Union{Array{T<:FixedSizeArrays.Vec{N, T}, 2}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N, T}, 2}, Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N, T}, 2}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.11)  2D matrices of vectors are 2D vector field with a an unicode arrow as the default

[_default{T<:FixedSizeArrays.Vec{N, T}}(main::Union{Array{T<:FixedSizeArrays.Vec{N, T}, 3}, GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N, T}, 3}, Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N, T}, 3}}},  s::GLAbstraction.Style{StyleValue},  data::Dict{K, V})](GLVisualize.md#method___default.12)  3D matrices of vectors are 3D vector field with a pyramid (arrow) like default

[call{T, N}(::Type{GLVisualize.Grid{N, T<:Range{T}}},  a::AbstractArray{T, N},  ranges::Tuple)](GLVisualize.md#method__call.1)  This constructor constructs a grid from ranges given as a tuple.

[meshparticle(p,  s,  data)](GLVisualize.md#method__meshparticle.1)  This is the main function to assemble particles with a GLNormalMesh as a primitive

[projection_switch(width,  mousehover,  mouse_buttons_pressed)](GLVisualize.md#method__projection_switch.1)  creates a button that can switch between orthographic and perspective projection

[sprites(p,  s,  data)](GLVisualize.md#method__sprites.1)  Main assemble functions for sprite particles.

