
function edit{T <: Union(AbstractFixedVector, Real)}(style::Style{:Default}, numbertex::Texture{T, 1, 2}, customization::Dict{Symbol,Any})

  backgroundcolor = customization[:backgroundcolor] 
  screen          = customization[:screen] 
  camera          = screen.orthographiccam
  color           = customization[:color] 
  maxdigits       = customization[:maxdigits] 
  maxlength       = customization[:maxlength] 
  model           = customization[:model] 
  font            = customization[:font] 

  numbers         = data(numbertex) # get data from texture/video memory
  text            = Array(GLGlyph{Uint16}, int(size(numbers,1)*maxdigits), size(numbers, 2))

  fill!(text, GLGlyph()) # Fill text array with blanks, as we don't need all of them

  # handle real values 
  Base.stride(x::Real, i)       = 1
  # remove f0 
  makestring(x::Integer)        = string(int(x))
  makestring(x::FloatingPoint)  = string(float64(x))
  makestring{T}(x::Vector1{T})  = string(float64(x[1]))
  makestring{T}(x::Vector1{T}, maxlen) = makestring(float64(x[1]), maxlen)

  makestring(x::Integer, maxlen) = begin
    tmp = string(int(x))
    len = length(tmp)
    if len > maxlen
        tmp = tmp[1:maxlen]
    elseif len < maxlen
      tmp = rpad(tmp, maxlen, " ")
    end
    tmp
  end
  makestring(x::FloatingPoint, maxlen) = begin
    tmp = string(float64(x))
    len = length(tmp)
    if len > maxlen
        tmp = tmp[1:maxlen]
    elseif len < maxlen
      tmp = rpad(tmp, maxlen, "0")
    end
    tmp
  end
  textgpu     = Texture(text, keepinram=true)
  customization[:style_group] = Texture([color])
  customization[:textlength]  = length(textgpu)
  obj         = visualize(style, textgpu, customization)

  startposition   = Uint16[0,0]
  positionrunner  = startposition

  maxlength = 5
  for i=1:size(numbers,1)
    for j=1:size(numbers, 2)
      number = numbers[i,j]
      i3 = ((i-1)*maxlength) + 1
      textgpu[i3:i3+maxlength-1, j:j] = GLGlyph{Uint16}[GLGlyph(c, positionrunner[1], positionrunner[2]+k-1, 0) for (k,c) in enumerate(makestring(number, maxlength))]
      positionrunner += [0, maxlength+1]
    end
    positionrunner = startposition + [i,0]
  end
  selectiondata = lift(first, SELECTION[:mouse_hover])
  # We allocated more space on the gpu then needed (length(numbers)*maxdigits)
  # So we need to update the render method, to render only length(numbers) * maxlength
  obj[:postrender, renderinstanced] = (obj.vertexarray, length(textgpu))
  # We allocated more space on the gpu then needed (length(numbers)*maxdigits)
  # So we need to update the render method, to render only length(numbers) * maxlength
  # ([numbers], zero(eltype(numbers)), -1, -1, -1, Vector2(0.0))
  number_lift = foldl(([numbers], zero(eltype(numbers)), -1, -1, -1, Vector2(0.0)), screen.inputs[:mouseposition], screen.inputs[:mousebuttonspressed], selectiondata) do v0, mposition, mbuttons, selection
    numbers0, value0, inumbers0, igpu0, mbutton0, mposition0 = v0
    # if over a number           && nothing selected &&         only           left mousebutton clicked
    if selection[1] == obj.id && inumbers0 == -1 && length(mbuttons) == 1 && in(0, mbuttons)
      iorigin   = selection[2]
      inumbers  = div(iorigin, maxlength) + 1
      igpu      = int((iorigin - (iorigin%maxlength)) + 1) # get the first index of the number
      return (numbers0, numbers0[inumbers], inumbers, igpu, 0, mposition)
    end
    # if a number is selected && previous click was left && still only left button ist clicked
    if inumbers0 > 0 && mbutton0 == 0 && length(mbuttons) == 1 && in(0, mbuttons) 
      xdiff                    = mposition[1] - mposition0[1]
      numbers0[inumbers0]      = value0 + (float32(xdiff)/ 50.0f0)
      numbertex[inumbers0]     = numbers0[inumbers0]
      a = mod(inumbers0-1, size(numbers0, 1))
      b = div(inumbers0-1, size(numbers0, 1))
      for (k,c) in enumerate(makestring(numbers0[inumbers0], maxlength))
        textgpu[igpu0+k-1] = GLGlyph(c, a, (b-1)+b*maxlength+k, 0)
      end
      return (numbers0, value0, inumbers0, igpu0, 0, mposition0)
    end
    return (numbers0, zero(eltype(numbers0)), -1, -1, -1, Vector2(0.0))
  end

  obj, numbertex
end


# remove f0 
makestring(x::Integer)        = string(int(x))
makestring(x::FloatingPoint)  = string(float64(x))
makestring{T}(x::Vector1{T})  = string(float64(x[1]))
makestring{T}(x::Vector1{T}, maxlen) = makestring(float64(x[1]), maxlen)
makestring(x::Integer, maxlen) = begin
  tmp = string(int(x))
  len = length(tmp)
  if len > maxlen
      tmp = tmp[1:maxlen]
  elseif len < maxlen
    tmp = rpad(tmp, maxlen, " ")
  end
  tmp
end
makestring(x::FloatingPoint, maxlen) = begin
  tmp = string(float64(x))
  len = length(tmp)
  if len > maxlen
      tmp = tmp[1:maxlen]
  elseif len < maxlen
    tmp = rpad(tmp, maxlen, "0")
  end
  tmp
end


function edit{T <: Union(AbstractVector, Real)}(style::Style, numbers::T, customization::Dict{Symbol,Any})

  backgroundcolor = customization[:backgroundcolor] 
  screen          = customization[:screen] 
  camera          = screen.orthographiccam
  color           = customization[:color] 
  maxdigits       = customization[:maxdigits] 
  maxlength       = customization[:maxlength] 
  model           = customization[:model]
  font            = customization[:font] 

  if ndims(numbers) == 2
    xn, yn = size(numbers)
  elseif ndims(numbers) == 1 || ndims(numbers) == 0
    xn, yn = length(numbers), 1
  else
    error("Dimension Missmatch. Wanted: 0D,1D, 2D Vector. Got: ", typeof(numbers), " ndims: ", ndims(numbers))
  end

  text        = Array(GLGlyph{Uint16}, int(xn*maxdigits), yn)
  fill!(text, GLGlyph()) # Fill text array with blanks, as we don't need all of them
  
  textgpu     = Texture(text)
  customization[:style_group] = Texture([color])
  customization[:textlength]  = length(textgpu)
  obj         = visualize(style, textgpu, customization)

  startposition   = Uint16[0,0]
  positionrunner  = startposition

  maxlength = 5
  for i=1:xn
    for j=1:yn
      number = numbers[i,j]
      i3 = ((i-1)*maxlength) + 1
      textgpu[i3:i3+maxlength-1, j:j] = GLGlyph{Uint16}[GLGlyph(c, positionrunner[1], positionrunner[2]+k-1, 0) for (k,c) in enumerate(makestring(number, maxlength))]
      positionrunner += [0, maxlength+1]
    end
    positionrunner = startposition + [i,0]
  end
  selectiondata = lift(first, SELECTION[:mouse_hover])
  # We allocated more space on the gpu then needed (length(numbers)*maxdigits)
  # So we need to update the render method, to render only length(numbers) * maxlength
  obj[:postrender, renderinstanced] = (obj.vertexarray, length(textgpu))
  # We allocated more space on the gpu then needed (length(numbers)*maxdigits)
  # So we need to update the render method, to render only length(numbers) * maxlength
  # ([numbers], zero(eltype(numbers)), -1, -1, -1, Vector2(0.0))
  number_lift = foldl(([numbers], zero(eltype(numbers)), -1, -1, -1, Vector2(0.0)), screen.inputs[:mouseposition], screen.inputs[:mousebuttonspressed], selectiondata) do v0, mposition, mbuttons, selection
    numbers0, value0, inumbers0, igpu0, mbutton0, mposition0 = v0
    # if over a number           && nothing selected &&         only           left mousebutton clicked
    if selection[1] == obj.id && inumbers0 == -1 && length(mbuttons) == 1 && in(0, mbuttons)
      iorigin   = selection[2]
      inumbers  = div(iorigin, maxlength) + 1
      igpu      = int((iorigin - (iorigin%maxlength)) + 1) # get the first index of the number
      return (numbers0, numbers0[inumbers], inumbers, igpu, 0, mposition)
    end
    # if a number is selected && previous click was left && still only left button ist clicked
    if inumbers0 > 0 && mbutton0 == 0 && length(mbuttons) == 1 && in(0, mbuttons) 
      xdiff                    = mposition[1] - mposition0[1]
      numbers0[inumbers0]      = value0 + (float32(xdiff)/ 50.0f0)
      #numbertex[inumbers0]     = numbers0[inumbers0]
      a = mod(inumbers0-1, size(numbers0, 1))
      b = div(inumbers0-1, size(numbers0, 1))
      for (k,c) in enumerate(makestring(numbers0[inumbers0], maxlength))
        textgpu[igpu0+k-1] = GLGlyph(c, a, (b-1)+b*maxlength+k, 0)
      end
      return (numbers0, value0, inumbers0, igpu0, 0, mposition0)
    end
    return (numbers0, zero(eltype(numbers0)), -1, -1, -1, Vector2(0.0))
  end
  convert2{XX}(::Type{XX}, x::Vector{XX}) = first(x)
  convert2(t::Type, x) = convert(t, x)
  obj, lift(x->convert2(T,first(x)), number_lift)
end
