function include_all(folder::String)
  for file in readdir(folder)
    if endswith(file, ".jl")
        include(joinpath(folder, file))
    end
  end
end



function Base.split(condition::Function, associative::Associative)
  A = similar(associative)
  B = similar(associative)
  for (key, value) in associative
    if condition(key, value)
      A[key] = value
    else
      B[key] = value
    end
  end
  A, B
end