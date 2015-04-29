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

function fold_loop(v0, v1)
  _, range = v1
  v0 == last(range) && return first(range) 
  v0+step(range)
end

function loop(range::Range, fps=30.0; stop_when=GLVisualize.ROOT_SCREEN.inputs[:open])
  foldl(fold_loop, first(range), lift(tuple, fpswhen(stop_when, fps), range))
end

function fold_bounce(v0, v1)
  _, range = v1
  val, direction = v0
  val += step(range)*direction
  if val > last(range) || val < first(range) 
    direction = -direction
    val += step(range)*direction
  end
  (val, direction)
end

function bounce{T}(range::Range{T}, fps=30.0; stop_when=GLVisualize.ROOT_SCREEN.inputs[:open])
  lift(first, foldl(fold_bounce, (first(range), one(T)), lift(tuple, fpswhen(stop_when, fps), range)))
end
