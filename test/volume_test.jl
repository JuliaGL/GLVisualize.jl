#using GLVisualize

immutable Vec3{T}
    x::T
    y::T
    z::T
end
x{T}(::Type{Vec3{T}}) = println(T)

x(Vec3)