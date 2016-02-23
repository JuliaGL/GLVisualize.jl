`GLVisualize.clicked`
args: `(::GLAbstraction.RenderObject, ::GLAbstraction.MouseButton, ::GLWindow.Screen)`
Returns two signals, one boolean signal if clicked over `robj` and another one that consists of the object clicked on and another argument indicating that it's the first click



`GLVisualize.sprites`
args: `(::Any, ::Any, ::Any)`
Main assemble functions for sprite particles. Sprites are anything like distance fields, images and simple geometries



`GLVisualize.is_hovering`
args: `(::GLAbstraction.RenderObject, ::GLWindow.Screen)`
Returns a boolean signal indicating if the mouse hovers over `robj`



`GLVisualize._default`
args: `(::Union{Array{T<:AbstractFloat,2},GLAbstraction.GPUArray{T<:AbstractFloat,2},Reactive.Signal{Array{T<:AbstractFloat,2}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
Matrices of floats are represented as 3D barplots with cubes as primitive

args: `(::Tuple{P<:Union{Char,GLVisualize.Shape,GeometryTypes.AbstractGeometry{N,T}},Union{Array{T<:FixedSizeArrays.Vec{N,T},N},GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N,T},N},Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N,T},N}}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
Vectors with `Vec` as element type are treated as vectors of rotations. The position is assumed to be implicitely on the grid the vector defines (1D,2D,3D grid)

args: `(::GeometryTypes.GeometryPrimitive{T,N}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
We plot simple Geometric primitives as particles with length one. At some point, this should all be appended to the same particle system to increase performance.

args: `(::Union{Array{T<:FixedSizeArrays.Point{N,T},1},GLAbstraction.GPUArray{T<:FixedSizeArrays.Point{N,T},1},Reactive.Signal{Array{T<:FixedSizeArrays.Point{N,T},1}}}, ::GLAbstraction.Style{:speed}, ::Dict{K,V})`
This is the most primitive particle system, which uses simple points as primitives. This is supposed to be very fast!

args: `(::Union{Array{T<:AbstractFloat,1},GLAbstraction.GPUArray{T<:AbstractFloat,1},Reactive.Signal{Array{T<:AbstractFloat,1}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
Vectors of floats are treated as barplots, so they get a HyperRectangle as default primitive.

args: `(::Union{Array{T<:FixedSizeArrays.Vec{N,T},3},GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N,T},3},Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N,T},3}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
3D matrices of vectors are 3D vector field with a pyramid (arrow) like default primitive.

args: `(::Tuple{P<:Union{Char,GLVisualize.Shape,GeometryTypes.AbstractGeometry{2,T},Type{T}},Union{Array{T<:AbstractFloat,N},GLAbstraction.GPUArray{T<:AbstractFloat,N},Reactive.Signal{Array{T<:AbstractFloat,N}}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
arrays of floats with the sprite primitive type (2D geometry + picture like), will be spaced out on a grid defined by `ranges` and will use the floating points as the z position for the primitives.

args: `(::Union{Array{T<:FixedSizeArrays.Vec{N,T},2},GLAbstraction.GPUArray{T<:FixedSizeArrays.Vec{N,T},2},Reactive.Signal{Array{T<:FixedSizeArrays.Vec{N,T},2}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
2D matrices of vectors are 2D vector field with a an unicode arrow as the default primitive.

args: `(::Union{Reactive.Signal{S<:AbstractString},S<:AbstractString}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
Transforms text into a particle system of sprites, by inferring the texture coordinates in the texture atlas, widths and positions of the characters.

args: `(::Union{Array{FixedSizeArrays.Point{N,T},1},GLAbstraction.GPUArray{FixedSizeArrays.Point{N,T},1},Reactive.Signal{Array{FixedSizeArrays.Point{N,T},1}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
Vectors of n-dimensional points get ndimensional rectangles as default primitives. (Particles)

args: `(::Tuple{P<:GeometryTypes.AbstractGeometry{N,T},Union{Array{T<:AbstractFloat,N},GLAbstraction.GPUArray{T<:AbstractFloat,N},Reactive.Signal{Array{T<:AbstractFloat,N}}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
arrays of floats with any geometry primitive, will be spaced out on a grid defined by `ranges` and will use the floating points as the height for the primitives (`scale_z`)

args: `(::Tuple{P<:Union{Char,GLVisualize.Shape,GeometryTypes.AbstractGeometry{2,T},Type{T}},Union{Array{T<:AbstractFloat,1},GLAbstraction.GPUArray{T<:AbstractFloat,1},Reactive.Signal{Array{T<:AbstractFloat,1}}}}, ::GLAbstraction.Style{StyleValue}, ::Dict{K,V})`
Sprites primitives with a vector of floats are treated as something barplot like



`GLVisualize.dragged_on`
args: `(::GLAbstraction.RenderObject, ::GLAbstraction.MouseButton, ::GLWindow.Screen)`
Returns a signal with the difference from dragstart and current mouse position, and the index from the current ROBJ id.



`GLVisualize.meshparticle`
args: `(::Any, ::Any, ::Any)`
This is the main function to assemble particles with a GLNormalMesh as a primitive



`GLVisualize.projection_switch`
args: `(::Any, ::Any, ::Any)`
creates a button that can switch between orthographic and perspective projection



`GLVisualize.Grid{N,T<:Range{T}}`
args: `(::AbstractArray{T,N}, ::Tuple)`
This constructor constructs a grid from ranges given as a tuple. Due to the approach, the tuple `ranges` can consist of NTuple(2, T) and all kind of range types. The constructor will make sure that all ranges match the size of the dimension of the array `a`.



`GLVisualize.cubecamera`
args: `(::Any)`
Creates a camera which is steered by a cube for `window`.



`GLVisualize.visualize`
args: `(::Tuple{Any}, ::Tuple{Any,Symbol})`
Creates a default visualization for any value. The dafaults can be customized via the key word arguments and the style parameter. The style can change the the look completely (e.g points displayed as lines, or particles), while the key word arguments just alter the parameters of one visualization. Always returns a context, which can be displayed on a window via view(::Context, [display]).
