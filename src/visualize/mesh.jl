import Meshes
immutable Face{T} <: AbstractFixedVector{3}
    v1::T
    v2::T
    v3::T
end
immutable Triangle{T <: AbstractFixedVector{3}}
    v1::T
    v2::T
    v3::T
end

immutable UV{T} <: AbstractFixedVector{2}
    u::T
    v::T
end
immutable Vertex{T} <: AbstractFixedVector{3}
    x::T
    y::T
    z::T
end
immutable Normal{T} <: AbstractFixedVector{3}
    x::T
    y::T
    z::T
end

immutable Material{T}
    diffuse::RGB{T}
    ambient::RGB{T}
    specular::RGB{T}
    specular_exponent::T
end
immutable TextureUsed{T}
    diffuse::T
    ambient::T
    specular::T
    bump::T
end

immutable GLMesh{Attributes}
    data::Dict{Symbol, Any}
    material::Material
    textures::Dict{Symbol, Matrix}
    model::Matrix4x4
end



function gen_normals(faces, verts)
  normals_result = fill(Vec3(0), length(verts))
  verts = reinterpret(Vec3, verts)
  for face in faces
    i1 = int(face.(1)) +1
    i2 = int(face.(2)) +1
    i3 = int(face.(3)) +1

    v1 = verts[i1]
    v2 = verts[i2]
    v3 = verts[i3]
    a = v2 - v1
    b = v3 - v1
    n = cross(a,b)
    normals_result[i1] = n+normals_result[i1]
    normals_result[i2] = n+normals_result[i2]
    normals_result[i3] = n+normals_result[i3]
  end
  map(unit, normals_result)
  reinterpret(Normal{Float32}, normals_result)
end

Material() = Material(RGB(0.9f0), RGB(0.9f0), RGB(0.9f0), 90f0)

function GLMesh(data...; material=Material(), textures=@compat(Dict(:default => fill(rgbaU8(0,0,0,0), 1,1))), model=eye(Mat4))
    result = (Symbol => DataType)[]
    meshattributes = Dict{Symbol, Any}()
    for elem in data
        typ                     = isa(elem, Vector) ? eltype(elem) : typeof(elem)
        keyname                 = symbol(lowercase(replace(string(typ.name.name), r"\d", "")))
        result[keyname]         = typ
        meshattributes[keyname] = elem
    end
    #sorting of parameters... Solution a little ugly for my taste
    result = sort(map(x->x, result))
    GLMesh{tuple(map(x->x[2], result)...)}(meshattributes, material, textures, model)
end
Base.getindex(m::GLMesh, key::Symbol) = m.data[key]
Base.setindex!(m::GLMesh, arr, key::Symbol) = m.data[key] = arr
function Base.show(io::IO, m::GLMesh)
    println(io, "Mesh:")
    maxnamelength = 0
    maxtypelength = 0
    names = map(m.data) do x
        n = string(x[1])
        t = string(eltype(x[2]).parameters...)
        namelength = length(n)
        typelength = length(t)
        maxnamelength = maxnamelength < namelength ? namelength : maxnamelength
        maxtypelength = maxtypelength < typelength ? typelength : maxtypelength

        return (n, t, length(x[2]))
    end

    for elem in names
        kname, tname, alength = elem
        namespaces = maxnamelength - length(kname)
        typespaces = maxtypelength - length(tname)
        println(io, "   ", kname, " "^namespaces, " : ", tname, " "^typespaces, ", length: ", alength)
    end
end

function Base.convert{T}(::Type{Face{T}}, face::Meshes.Face)
    Face{T}(
        face.v1,face.v2,face.v3
    )
end
function Base.convert{T}(::Type{Vertex{T}}, vertex::Vector3)
    Vertex{T}(
        vertex.(1),vertex.(2),vertex.(3)
    )
end
function Base.convert{T, TI}(::Type{GLMesh{( Face{TI}, Normal{T},Vertex{T})}}, mesh::Meshes.Mesh)
    faces = map(mesh.faces) do face
        Face{TI}(face.v1-1, face.v2-1, face.v3-1) 
    end
    vertices = map(mesh.vertices) do vertex
        convert(Vertex{T}, vertex)
    end
    GLMesh(faces, vertices, gen_normals(faces, vertices))
end

function texturesused(mesh::GLMesh)
    usedtextures = fill(-1f0, length(names(TextureUsed)))
    for (i,attribute) in enumerate(names(TextureUsed))
        usedtextures[i] = haskey(mesh.textures, attribute) ? float32(i)-1 : -1f0
    end
    println(usedtextures)
    usedtextures
end
RGBAU8 = AlphaColorValue{RGB{Ufixed8}, Ufixed8}
Color.rgba(r::Real, g::Real, b::Real, a::Real)    = AlphaColorValue(RGB{Float32}(r,g,b), float32(a))
rgbaU8(r::Real, g::Real, b::Real, a::Real)  = AlphaColorValue(RGB{Ufixed8}(r,g,b), ufixed8(a))
#GLPlot.toopengl{T <: AbstractRGB}(colorinput::Input{T}) = toopengl(lift(x->AlphaColorValue(x, one(T)), RGBA{T}, colorinput))
tohsva(rgba)     = AlphaColorValue(convert(HSV, rgba.c), rgba.alpha)
torgba(hsva)     = AlphaColorValue(convert(RGB, hsva.c), hsva.alpha)
tohsva(h,s,v,a)  = AlphaColorValue(HSV(float32(h), float32(s), float32(v)), float32(a))
Base.convert{T <: AbstractAlphaColorValue}(typ::Type{T}, x::AbstractAlphaColorValue) = AlphaColorValue(convert(RGB{eltype(typ)}, x.c), convert(eltype(typ), x.alpha))

Color.RGB{T}(x::T) = RGB{T}(x,x,x)




unitGeometry{T}(geometry::Vector{Vertex{T}}) = reinterpret(Vertex{T}, unitGeometry(reinterpret(Vector3{T}, geometry)))
function unitGeometry{T}(geometry::Vector{Vector3{T}})
    assert(!isempty(geometry))

    xmin = typemax(T)
    ymin = typemax(T)
    zmin = typemax(T)

    xmax = typemin(T)
    ymax = typemin(T)
    zmax = typemin(T)

    for vertex in geometry
        xmin = min(xmin, vertex[1])
        ymin = min(ymin, vertex[2])
        zmin = min(zmin, vertex[3])

        xmax = max(xmax, vertex[1])
        ymax = max(ymax, vertex[2])
        zmax = max(zmax, vertex[3])
    end

    xmiddle = xmin + (xmax - xmin) / 2;
    ymiddle = ymin + (ymax - ymin) / 2;
    zmiddle = zmin + (zmax - zmin) / 2;
    scale = 2 / max(xmax - xmin, ymax - ymin, zmax - zmin);

    result = similar(geometry)

    for i = 1:length(result)
        result[i] = Vector3{T}((geometry[i][1] - xmiddle) * scale,
                               (geometry[i][2] - ymiddle) * scale,
                               (geometry[i][3] - zmiddle) * scale
                    );
    end

    return result
end
function collect_for_gl(mesh::GLMesh) 
    mat = RGB{Float32}[
        mesh.material.(1),
        mesh.material.(2),
        mesh.material.(3),
        RGB(mesh.material.(4)),
    ]
    maps = collect(values(mesh.textures))
    texmap = convert(Vector{typeof(maps[1])}, maps)
    merge(
        [k => isa(v,Vector) ? (eltype(v) <: Face ? indexbuffer(v) : GLBuffer(v)) : v for (k,v) in mesh.data], 
        @compat(Dict(
        :texture_maps  => Texture(texmap),
        :textures_used => texturesused(mesh),
        :material      => mat,
        :model         => mesh.model
    )))
end
toopengl(mesh::Meshes.Mesh; camera=pcamera) = toopengl(convert(GLMesh{(Face{GLuint}, Normal{Float32}, Vertex{Float32})}, mesh), camera=camera)

const MESH_SHADER = Any[]
const light       = Vec3[Vec3(1.0,0.9,0.8), Vec3(0.01,0.01,0.1), Vec3(1.0,0.9,0.9), Vec3(-5.0, -7.0,10.0)]
function toopengl(mesh::GLMesh{(Face{GLuint}, Normal{Float32}, Vertex{Float32})}; camera=pcamera)
    if isempty(MESH_SHADER)
        push!(MESH_SHADER, TemplateProgram(Pkg.dir("GLPlot", "src", "shader", "standard.vert"), Pkg.dir("GLPlot", "src", "shader", "phongblinn.frag")))
    end
    shader = first(MESH_SHADER)
    #cam     = customizations[:camera]
    #light   = customizations[:light]
    #mesh[:vertex] = unitGeometry(mesh[:vertex])
    data = merge(collect_for_gl(mesh), @compat(Dict(
        :view            => camera.view,
        :projection      => camera.projection,
        :model           => eye(Mat4),
        :eyeposition     => camera.eyeposition,
        :light           => light,
        :uv              => Vec2(-1),
    )))
    ro = RenderObject(data, shader)
    prerender!(ro, glEnable, GL_DEPTH_TEST, glDepthFunc, GL_LEQUAL, glDisable, GL_CULL_FACE, enabletransparency)
    postrender!(ro, render, ro.vertexarray)
    ro
end

