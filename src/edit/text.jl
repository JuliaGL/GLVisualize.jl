

function filtereselection(v0, selection, buttons)
  if !isempty(buttons) && first(buttons) == 0  # if any button is pressed && its the left button
    selection #return diffed index
  else
    Vector2(-1)
  end
end

function haschanged(v0, selection)
  (v0[2] != selection, selection)
end
function edit(style::Style{:Default}, text::String, custumization::Dict{Symbol, Any})
  obj = visualize(text, style; custumization...)
  edit(obj[:text], obj)
end
function edit(style::Style{:Default}, textGPU::Texture{GLGlyph{Uint16}, 4, 2}, obj::RenderObject, custumization::Dict{Symbol, Any})
  screen = custumization[:screen]
  specialkeys = filteritems(screen.inputs[:buttonspressed], [GLFW.KEY_LEFT_CONTROL, GLFW.KEY_ENTER, GLFW.KEY_BACKSPACE], IntSet())

  selectiondata = lift(first, SELECTION[:mouse_hover])
  # Filter out the selected index,
  changed = lift(first, foldl(haschanged, (true, selectiondata.value), selectiondata))

  leftclick_selection = foldl(filtereselection, Vector2(-1), keepwhen(changed, Vector2(-1), selectiondata), screen.inputs[:mousebuttonspressed])
  glypharray = vec(data(textGPU))
  changed    = false
  v00        = (obj, obj.alluniforms[:textlength], textGPU, glypharray, leftclick_selection.value, changed)
  output     = foldl(edit_text, v00, leftclick_selection, screen.inputs[:unicodeinput], specialkeys)
  textsignal = lift(filter(v00, output) do x
    x[end] # <-has changed
  end) do x
    utf16(x[4][1:x[2]]) #x[4] <- glypharray, x[2] <- textlength
  end
  return (obj, textsignal)
end
function pressed{T<:Integer}(keys::Vector{T}, keyset)
    length(keyset) == length(keys) && all(keys) do x
        in(x, keyset)
    end
end
function edit_text(v0, selection1, unicode_keys, special_keys)
    # selection0 tracks, where the carsor is after a new character addition, selection10 tracks the old selection
    obj, textlength, textGPU, glypharray, selection0, changed = v0
    selected_object, selected_index = selection0
    selected_index += 1
    chars_added = 0
    edit_inbound = selected_index<=textlength+1 && selected_index>0 && selected_object == obj.id
    if selection1 != Vector2(-1) # if a new index was selected update selection
        return (obj, textlength, textGPU, glypharray, selection1, false)
    elseif edit_inbound && !(!isempty(unicode_keys) && IntSet(GLFW.MOD_SHIFT)==special_keys) && (!isempty(special_keys) || !isempty(unicode_keys))# something will get edited
        if !isempty(special_keys) && isempty(unicode_keys)
            if in(GLFW.KEY_BACKSPACE, special_keys) && selected_index>1
                splice!(glypharray, selected_index-1)
                chars_added = -1
            elseif in(GLFW.KEY_ENTER, special_keys)
                insert!(glypharray, selected_index, GLGlyph('\n', 0,0,0))
                chars_added = 1
            elseif pressed([GLFW.KEY_LEFT_CONTROL, GLFW.KEY_V], special_keys)
                p = clipboard()
                pasted = [GLGlyph(c,0,0,0) for c in p]
                if selected_index == 1
                  glypharray = [pasted, glypharray]
                elseif selected_index == textlength+1
                  glypharray = [glypharray, pasted]
                elseif selected_index>1 && selected_index>=textlength
                  glypharray = [sub(glypharray, 1:selected_index), pasted, sub(glypharray, selected_index:length(glypharray))]
                else
                  error("invalid text cursor index. Index: ", selected_index)
                end
                chars_added = length(p)
            end
        elseif edit_inbound && !isempty(unicode_keys) && (isempty(special_keys) || IntSet(GLFW.MOD_SHIFT)==special_keys)# else unicode input must have occured
            insert!(glypharray, selected_index, GLGlyph(first(unicode_keys), 0,0,0))
            chars_added = 1
        end
        if chars_added != 0
            textlength  += chars_added
            newselection = chars_added + selected_index
            selection0   = Vector2(selected_object, max(min(newselection, textlength+1), 1)-1)
            update_glyphpositions!(glypharray)
            if textlength > length(textGPU)
              resize!(textGPU, [size(textGPU,1), size(textGPU,2)*2])
            end
            remaining = div(textlength, 1024)
            if remaining < 1
                textGPU[1:textlength, 1:1] = reshape(glypharray[1:textlength], textlength)
            else
                textGPU[1:end, 1:remaining] = reshape(glypharray[1:1024*remaining], 1024, remaining)
            end
            obj[:postrender, renderinstanced] = (obj.vertexarray, textlength)
        end
        return (obj, textlength, textGPU, glypharray, selection0, true)
    end
    return (obj, textlength, textGPU, glypharray, selection0, false)
end


# Filters a signal. If any of the items is in the signal, the signal is returned.
# Otherwise default is returned
function filteritems{T}(a::Signal{T}, items, default::T)
  lift(a) do signal
    if any(item-> in(item, signal), items)
      signal
    else
      default 
    end
  end
end



function Base.delete!(s::Array{GLGlyph{Uint16}, 1}, Index::Integer)
  if Index == 0
    return s
  elseif Index == length(s)
    return s[1:end-1]
  end
  return [s[1:max(Index-1, 0)], s[min(Index+1,length(s)):end]]
end

addchar(s::Array{GLGlyph{Uint16}, 1}, glyph::Char, Index::Integer) = addchar(s, GLGlyph(glyph, 0, 0, 0), int(Index))
function addchar(s::Array{GLGlyph{Uint16}, 1}, glyph::GLGlyph{Uint16}, i::Integer)
  if i == 0
    return [glyph, s]
  elseif i == length(s)
    return [s, glyph]
  elseif i > length(s) || i < 0
    return s
  end
  return [s[1:i], glyph, s[i+1:end]]
end
