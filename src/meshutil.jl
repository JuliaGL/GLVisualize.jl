import Base.convert
# tries to find the concrete type with preference on a.
use_concrete(a::DataType, b::DataType) = isleaftype(a) ? a : isleaftype(b) ? b : error("no concrete type given")

merge(m1::Mesh, rest::Mesh...) = merge(tuple(m1, rest...))
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
function merge{N, A <: UVAttribute}(m::NTuple{N, A})
    a = first(m)
    uv = a.uv
    for elem in m[2:end]
        append!(uv, elem.uv)
    end
    return A(uv)
end
function merge{N, A <: NormalAttribute}(m::NTuple{N, A})
    a = first(m)
    uv = a.normal
    for elem in m[2:end]
        append!(uv, elem.normal)
    end
    return A(uv)
end
function merge{N, A <: UVWAttribute}(m::NTuple{N, A})
    a = first(m)
    uvw = a.uvw
    for elem in m[2:end]
        append!(uvw, elem.uvw)
    end
    return A(uvw)
end


export collect_for_gl

function collect_for_gl(m::GLUVMesh)
    @compat Dict(
        :vertex => GLBuffer(vertices(m)),
        :_ => indexbuffer(faces(m)),
        :uv => GLBuffer(attributes(m).uv),
    )
end
function collect_for_gl(m::GLUVWMesh)
    @compat Dict(
        :vertex => GLBuffer(vertices(m)),
        :_      => indexbuffer(faces(m)),
        :uvw    => GLBuffer(attributes(m).uvw),
    )
end
function collect_for_gl(m::GLUVMesh2D)
    @compat Dict(
        :vertex => GLBuffer(vertices(m)),
        :_      => indexbuffer(faces(m)),
        :uv    => GLBuffer(attributes(m).uv),
    )
end
function collect_for_gl(m::GLNormalMesh)
    @compat Dict(
        :vertex => GLBuffer(vertices(m)),
        :_      => indexbuffer(faces(m)),
        :normal    => GLBuffer(attributes(m).normal),
    )
end
function collect_for_gl(m::GLMesh2D)
    @compat Dict(
        :vertex => GLBuffer(vertices(m)),
        :_      => indexbuffer(faces(m)),
    )
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
	uv = UV{T}[
        UV{T}(0, 1),
        UV{T}(0, 0),
        UV{T}(1, 0),
        UV{T}(1, 1)
    ]
end
function convert{T1, T2}(uvw::Type{UVW{T1}}, q::Quad{T2})
    T = use_concrete(T1, T2)
    v = UVW{T}[
        q.downleft,
        q.downleft + q.height,
        q.downleft + q.width + q.height,
        q.downleft + q.width
    ]
end

convert(::Type{PlainMesh}, q::Any) = MeshIO.PLAIN
function convert{ATTRIB <: HomogenousAttributes}(::Type{ATTRIB}, q::Union(Quad, Rectangle))
	ATTRIB(map(attributelist(ATTRIB)) do attrib
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

function convert{T}(::Type{UV{T}}, r::Rectangle)
    UV{T}[
        UV{T}(0, 0),
        UV{T}(0, 1),
        UV{T}(1, 1),
        UV{T}(1, 0)
    ]
end

function convert{ET, IT, A}(::Type{Mesh{Point2{ET}, Triangle{IT}, A}}, r::Rectangle)
    vertices = Point2{ET}[
        Point2{ET}(r.x, r.y),
        Point2{ET}(r.x, r.y + r.h),
        Point2{ET}(r.x + r.w, r.y + r.h),
        Point2{ET}(r.x + r.w, r.y)
    ]
    faces = Triangle{IT}[Triangle{IT}(0,1,2),Triangle{IT}(2,3,0)]
    a = convert(A, r)
    Mesh{Point2{ET}, Triangle{IT}, A}(vertices, faces, a)
end

#=
function RandSphere()
  N = 10
  sigma = 1.0
  distance = Float32[ sqrt(float32(i*i+j*j+k*k)) for i = -N:N, j = -N:N, k = -N:N ]
  distance = distance + sigma*rand(2*N+1,2*N+1,2*N+1)
  # Extract an isosurface.
  lambda = N-2*sigma # isovalue

  msh = Meshes.isosurface(distance,lambda)
  convert(GLMesh{(Face{GLuint}, Normal{Float32}, UV{Float32}, Vertex{Float32})}, msh)
end
=#