abstract AbstractLight
abstract AbstractShading

immutable ColorMap{T, L}
    colors::Vector{RGBA{T}}
    limits::Vec{T, 2}
    lookup::L
end
function ColorMap{L}(colormap, lookup::L, normalization=extrema(lookup))
    ColorMap{Float32, L}(map(RGBA{Float32}, colormap), normalization, lookup)
end

@with_kw immutable Shading{T} <: AbstractShading
    ambient::RGB{T} = RGB(0.3f0, 0.3f0, 0.3f0)
    specular::RGB{T} = RGB(1.0f0, 1.0f0, 1.0f0)
    shininess::T = 8.0f0
end
Shading() = Shading{Float32}()

@with_kw immutable PointLight{T} <: AbstractLight
    position::Vec{3, T} = Vec3f0(20)
    diffuse::RGB{T} = RGB(0.9f0, 0.9f0, 0.9f0)
    diffuse_power::T = 1f0
    specular::RGB{T} = RGB(1f0, 1f0, 1f0)
    specular_power::T = 1f0
end
PointLight() = PointLight{Float32}()

@with_kw immutable Scene{T, L <: AbstractLight}
    ambient_color::RGB{T} = RGB(0.1f0, 0.1f0, 0.1f0)
    lights::Vector{L} = [PointLight()]
end
Scene() = Scene{Float32, PointLight{Float32}}()

@with_kw immutable Visualization{Main, Style}
    main::Main
    children::Vector{Visualization} = Visualization[]
    shading::Shading{Float32} = Shading()
    parameters::Dict{Symbol, Any} = Dict{Symbol, Any}
    transformation = eye(Mat4f0)
    boundingbox = Signal(centered(AABB))
    scene = Scene()
end

"""
Allows to alias resources inside Visualizations
"""
immutable Alias
    sym::Symbol
end
macro alias_str(x)
    :(Alias(Symbol($x)))
end
