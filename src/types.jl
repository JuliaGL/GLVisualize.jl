typealias ArrayOrSignal{T, N} Union{Array{T, N}, Signal{Array{T, N}}}
typealias VecOrSignal{T} 	ArrayOrSignal{T, 1}
typealias MatOrSignal{T} 	ArrayOrSignal{T, 2}
typealias VolumeOrSignal{T} ArrayOrSignal{T, 3}

typealias ArrayTypes{T, N} Union{GPUArray{T, N}, ArrayOrSignal{T,N}}
typealias VecTypes{T} 		ArrayTypes{T, 1}
typealias MatTypes{T} 		ArrayTypes{T, 2}
typealias VolumeTypes{T} 	ArrayTypes{T, 3}

@enum Shape CIRCLE RECTANGLE ROUNDED_RECTANGLE DISTANCEFIELD TRIANGLE

immutable Grid{N, T <: Range}
    dims::NTuple{N, T}
end
Grid(ranges::Range...) = Grid(ranges)
function Grid{T, N}(a::Array{T, N})
	s = Vec{N, Float32}(size(a))
	smax = maximum(s)
	s = s./smax
	Grid(ntuple(Val{N}) do i
		linspace(0, s[i], size(a, i))
	end)
end
Base.length(p::Grid) = mapreduce(+, length, p.dims)

immutable Intensity{N, T} <: FixedVector{N, T}
	_::NTuple{N, T}
end
export Intensity


immutable GLVisualizeShader <: AbstractLazyShader
    paths  ::Tuple
    kw_args::Vector
    function GLVisualizeShader(paths...; kw_args...)
        paths = map(shader -> joinpath(shaderdir(), shader), paths)
        new(paths, vcat(kw_args, [
        	(:fragdatalocationc, [(0, "fragment_color"), (1, "fragment_groupid")]),
    		(:updatewhile, ROOT_SCREEN.inputs[:open]),
    		(:update_interval, 1.0),
        ]))
    end
end
