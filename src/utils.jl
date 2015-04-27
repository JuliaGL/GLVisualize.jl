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

macro visualize_gen(input, target)
    esc(quote 
        visualize(value::$input, s::Style, customizations=visualize_default(value, s)) = 
            visualize($target(value), s, customizations)

        function visualize(signal::Signal{$input}, s::Style, customizations=visualize_default(signal.value, s))
            tex = $target(signal.value)
            lift(update!, Input(tex), signal)
            visualize(tex, s, customizations)
        end
    end)
end