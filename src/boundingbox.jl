AbsoluteRectangle{N,T}(mini::Vec{N,T}, maxi::Vec{N,T}) = HyperRectangle{N,T}(mini, maxi-mini)

call(::Type{AABB}, a) = AABB{Float32}(a)
function call{T}(B::Type{AABB{T}}, a::Pyramid)
    w,h = a.width/T(2), a.length
    m = Vec{3,T}(a.middle)
    B(m-Vec{3,T}(w,w,0), m+Vec{3,T}(w, w, h))
end
call{T}(B::Type{AABB{T}}, a::Cube) = B(origin(a), widths(a))
call{T}(B::Type{AABB{T}}, a::AbstractMesh) = B(vertices(a))
call{T}(B::Type{AABB{T}}, a::NativeMesh) = B(gpu_data(a.data[:vertices]))


function call{T}(
        B::Type{AABB{T}},
        positions, scale, rotation,
        primitive::AABB{T}
    )

    ti = TransformationIterator(positions, scale, rotation)
    B(ti, primitive)
end
function call{T}(B::Type{AABB{T}}, instances::Instances)
    ti = TransformationIterator(instances)
    B(ti, B(instances.primitive))
end

function transform(translation, scale, rotation, points)
    _max = Vec3f0(typemin(Float32))
    _min = Vec3f0(typemax(Float32))
    for p in points
        x = scale.*Vec(p)
        x = Vec3f0(rotation*Vec(x, 1f0))
        x = Vec(translation)+x
        _min = min(_min, x)
        _max = max(_max, x)
    end
    AABB{Float32}(_min, _max-_min)
end

function call{T}(
        B::Type{AABB{T}}, ti::TransformationIterator, primitive::AABB{T}
    )
    trans_scale_rot, state = next(ti, start(ti))
    points = decompose(Point3f0, primitive)
    bb = transform(trans_scale_rot..., points)
    while !done(ti, state)
        trans_scale_rot, state = next(ti, state)
        translatet_bb = transform(trans_scale_rot..., points)
        bb = union(bb, translatet_bb)
    end
    bb
end
