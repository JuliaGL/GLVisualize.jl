#=
The text needs to be uploaded into a 2D texture, with 1D alignement, as there is no way to vary the row length, which would be a big waste of memory.
This is why there is the need, to prepare offsets information about where exactly new lines reside.
If the string doesn't contain a new line, the text is restricted to one line, which is uploaded into one 1D texture.
This is important for differentiation between multi-line and single line text, which might need different treatment
=#
function visualize(style::Style{:Default}, text::String, data::Dict{Symbol, Any})
  glypharray          = toglypharray(text)
  data[:style_group]  = Texture([data[:color]])
  data[:textlength]   = length(text) # needs to get remembered, as glypharray is usually bigger than the text
  data[:lines]        = count(x->x=='\n', text) 
  textGPU             = Texture(glypharray)
  # To make things simple for now, checks if the texture is too big for the GPU are done by 'Texture' and an error gets thrown there.
  return visualize(style, textGPU, data)
end

# This is the low-level text interface, which simply prepares the correct shader and cameras
function visualize(::Style{:Default}, text::Texture{GLGlyph{Uint16}, 4, 2}, data::Dict{Symbol, Any})
  screen             = data[:screen]
  camera             = screen.orthographiccam
  renderdata         = merge(data, data[:font].data) # merge font texture and uv informations -> details @ GLFont/src/types.jl

  view = @compat Dict(
    "GLSL_EXTENSIONS" => "#extension GL_ARB_draw_instanced : enable"
  )
  renderdata[:text]           = text
  renderdata[:projectionview] = camera.projectionview
  shader = TemplateProgram(
    Pkg.dir("GLText", "src", "textShader.vert"), Pkg.dir("GLText", "src", "textShader.frag"), 
    view=view, attributes=renderdata, fragdatalocation=[(0, "fragment_color"),(1, "fragment_groupid")]
  )
  obj = instancedobject(renderdata, data[:textlength], shader, GL_TRIANGLES, textboundingbox)
  prerender!(obj, enabletransparency, glDisable, GL_DEPTH_TEST, glDisable, GL_CULL_FACE,)
  return obj
end
function visualize(style::Style{:Default}, text::Vector{GLGlyph{Uint16}}, data::Dict{Symbol, Any})
  textstride = data[:stride]
  data[:textlength] = length(text) # remember text
  if length(text) % textstride != 0
    append!(text, Array(GLGlyph{Uint16}, textstride-(length(text)%textstride))) # append if can't be reshaped with 1024
  end
  data[:style_group]  = Texture([data[:color]])
  # To make things simple for now, checks if the texture is too big for the GPU are done by 'Texture' and an error gets thrown there.
  return visualize(style, Texture(reshape(text, textstride, div(length(text), textstride))), data)
end
function textboundingbox(obj)
  glypharray  = data(obj[:text]) 
  advance     = obj[:advance]  
  newline     = obj[:newline]  

  maxv = Vector3(typemin(Float32))
  minv = Vector3(typemax(Float32))
  glyphbox = Vec3(12,24,0)
  for elem in glypharray[1:obj.alluniforms[:textlength]]
    
    currentpos = elem.row*advance + elem.line*newline

    maxv = maxper(maxv, currentpos + glyphbox)
    minv = minper(minv, currentpos)
  end
  AABB(minv+newline, maxv)
end
