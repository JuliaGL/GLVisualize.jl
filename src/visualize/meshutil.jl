using MeshIO, GeometryTypes, FixedSizeArrays
import Base: merge, convert, show


# tries to find the concrete type with preference on a.
use_concrete(a::DataType, b::DataType) = isleaftype(a) ? a : isleaftype(b) ? b : error("no concrete type given")

merge(m::Mesh...) = merge(m)
merge{M <: Mesh}(m::Vector{M}) = merge(tuple(m...))

function merge{N, M <: Mesh}(m::NTuple{N, M})
	a = first(m)
    v = vertices(a)
    f = faces(a)
    for elem in m[2:end]
        append!(f, faces(elem) + length(v))
        append!(v, vertices(elem))
    end
    attribs = merge(map(attributes, m)) # merge all attributes
    return M(v, f, attribs)
end

function merge{N, A <: HomogenousAttributes}(m::NTuple{N, A})
	a = first(m)
    uv = a.uv
    for elem in m[2:end]
        append!(uv, elem.uv)
    end
    return A(uv)
end


immutable Quad{T}
	downleft::Vector3{T}
	width::Vector3{T}
	height::Vector3{T}
end

function normal(q::Quad)
    normal = normalize(cross(q.width, q.height))
    Vector3{T}[normal for i=1:4]
end

function convert{T1, T2}(::Type{Normal3{T1}}, q::Quad{T2})
	T = use_concrete(T1, T2)
	normal = normalize(cross(q.width, q.height))
    Normal3{T}[normal for i=1:4]
end
function convert{T1, T2}(uv::Type{UV{T1}}, q::Quad{T2})
	T = use_concrete(T1, T2)
	uv = Vector2{T}[
        Vector2{T}(0, 1),
        Vector2{T}(0, 0),
        Vector2{T}(1, 0),
        Vector2{T}(1, 1)
    ]
end
function convert{ATTRIB <: HomogenousAttributes, T}(::Type{ATTRIB}, q::Quad{T})
	ATTRIB(map(attributes(ATTRIB)) do attrib
		convert(attrib, q)
	end...)
end
function convert{M <: Mesh, T}(::Type{M}, q::Quad{T})
    v = Vector3{T}[
        q.downleft,
        q.downleft + q.height,
        q.downleft + q.width + q.height,
        q.downleft + q.width
    ]
    faces = [Triangle{T}(0,1,2), Triangle{T}(2,3,0)]
    M(v, faces, convert(attributes(M), q))
end



function convert{T <: Mesh}(meshtype::Type{T}, c::Cube)
	ET = eltype(vertices(T))
	xdir = Vector3{ET}(c.width[1],0,0)
	ydir = Vector3{ET}(0,c.width[2],0)
	zdir = Vector3{ET}(0,0,c.width[3])
	quads = [
        Quad(c.origin + zdir, 	xdir, ydir), # Top
        Quad(c.origin, 			ydir, xdir), # Bottom
        Quad(c.origin + xdir, 	ydir, zdir), # Right
        Quad(c.origin, 			zdir, ydir), # Left
        Quad(c.origin, 			xdir, zdir), # Back
        Quad(c.origin + ydir, 	zdir, xdir) #Front		
	]
	merge(map(meshtype, quads))
end

a = GLUVMesh(Cube(Vector3{Float32}(0,0,0), Vector3{Float32}(1,1,1)))


println(typeof(a))
println(a)