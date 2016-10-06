AbsoluteRectangle{N,T}(mini::Vec{N,T}, maxi::Vec{N,T}) = HyperRectangle{N,T}(mini, maxi-mini)

@compat (::Type{AABB})(a) = AABB{Float32}(a)
@compat function (B::Type{AABB{T}}){T}(a::Pyramid)
    w,h = a.width/T(2), a.length
    m = Vec{3,T}(a.middle)
    B(m-Vec{3,T}(w,w,0), m+Vec{3,T}(w, w, h))
end
@compat (B::Type{AABB{T}}){T}(a::Cube) = B(origin(a), widths(a))
@compat (B::Type{AABB{T}}){T}(a::AbstractMesh) = B(vertices(a))
@compat (B::Type{AABB{T}}){T}(a::NativeMesh) = B(gpu_data(a.data[:vertices]))


@compat function (B::Type{AABB{T}}){T}(
        positions, scale, rotation,
        primitive::AABB{T}
    )

    ti = TransformationIterator(positions, scale, rotation)
    B(ti, primitive)
end
@compat function (B::Type{AABB{T}}){T}(instances::Instances)
    ti = TransformationIterator(instances)
    B(ti, B(instances.primitive))
end

function transform(translation, scale, rotation, points)
    _max = Vec3f0(typemin(Float32))
    _min = Vec3f0(typemax(Float32))
    for p in points
        x = scale.*Vec3f0(p)
        rv = rotation*Vec4f0(x[1], x[2], x[3], 1f0)
        x = Vec3f0(rv[1], rv[2], rv[3])
        x = Vec3f0(translation)+x
        _min = min(_min, x)
        _max = max(_max, x)
    end
    AABB{Float32}(_min, _max-_min)
end

@compat function (B::Type{AABB{T}}){T}(
      ti::TransformationIterator, primitive::AABB{T}
    )
    state = start(ti)
    if done(ti, state)
        return primitive
    end
    tsr::Tuple{Point3f0, Vec3f0, Mat4f0}, state = next(ti, state)
    points = decompose(Point3f0, primitive)::Vector{Point3f0}
    bb = transform(tsr[1], tsr[2], tsr[3], points)
    while !done(ti, state)
        tsr, state = next(ti, state)
        translatet_bb = transform(tsr[1], tsr[2], tsr[3], points)
        bb = union(bb, translatet_bb)
    end
    bb
end
