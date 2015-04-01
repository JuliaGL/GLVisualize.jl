begin 
local color_chooser_shader = TemplateProgram(
  joinpath(shaderdir, "colorchooser.vert"), joinpath(shaderdir, "colorchooser.frag"), 
  fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")]
)

local COLOR_QUAD = genquad(Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(0, 1, 0))

#GLPlot.toopengl{T <: AbstractRGB}(colorinput::Input{T}) = toopengl(lift(x->AlphaColorValue(x, one(T)), RGBA{T}, colorinput))

function visualize{X <: AbstractAlphaColorValue}(style::Style, color::X, data)
  screen       = data[:screen]
  camera       = screen.orthographiccam

  rdata = merge(@compat(Dict(
    :vertex => GLBuffer(COLOR_QUAD[1]),
    :uv     => GLBuffer(COLOR_QUAD[2]),
    :index  => indexbuffer(COLOR_QUAD[4]),
  )), data)

  rdata[:view]       = camera.view
  rdata[:projection] = camera.projection
  rdata[:color]      = color

  obj = RenderObject(rdata, color_chooser_shader, color_chooser_boundingbox)

  prerender!(obj, glEnable, GL_DEPTH_TEST, glDepthFunc, GL_LESS, glDisable, GL_CULL_FACE, enabletransparency)#
  postrender!(obj, render, obj.vertexarray) # Render the vertexarray

  # hover is true, if mouse 
  hover = lift(SELECTION[:mouse_hover]) do selection
    selection[1][1] == obj.id
  end


  all_signals = foldl((tohsva(color), false, false, Vec2(0)), SELECTION[:mouse_hover]) do v0, selection

    hsv, hue_sat0, bright_trans0, mouse0 = v0
    mouse           = screen.inputs[:mouseposition].value
    mouse_clicked   = screen.inputs[:mousebuttonspressed].value

    hue_sat = in(0, mouse_clicked) && selection[1][1] == obj.id
    bright_trans = in(1, mouse_clicked) && selection[1][1] == obj.id
    

    if hue_sat && hue_sat0
      diff = mouse - mouse0
      hue = mod(hsv.c.h + diff[1], 360)
      sat = max(min(hsv.c.s + (diff[2] / 30.0), 1.0), 0.0)

      return (tohsva(hue, sat, hsv.c.v, hsv.alpha), hue_sat, bright_trans, mouse)
    elseif hue_sat && !hue_sat0
      return (hsv, hue_sat, bright_trans, mouse)
    end

    if bright_trans && bright_trans0
      diff    = mouse - mouse0
      brightness  = max(min(hsv.c.v - (diff[2]/100.0), 1.0), 0.0)
      alpha     = max(min(hsv.alpha + (diff[1]/100.0), 1.0), 0.0)

      return (tohsva(hsv.c.h, hsv.c.s, brightness, alpha), hue_sat0, bright_trans, mouse)
    elseif bright_trans && !bright_trans0
      return (hsv, hue_sat0, bright_trans, mouse)
    end

    return (hsv, hue_sat, bright_trans, mouse)
  end
  color1 = lift(x -> torgba(x[1]), all_signals)
  color1 = lift(x -> Vec4(x.c.r, x.c.g, x.c.b, x.alpha), Vec4, color1)
  hue_saturation = lift(x -> x[2], all_signals)
  brightness_transparency = lift(x -> x[3], all_signals)


  obj.uniforms[:color]                    = color1
  obj.uniforms[:hover]                    = hover
  obj.uniforms[:hue_saturation]           = hue_saturation
  obj.uniforms[:brightness_transparency]  = brightness_transparency

  return obj, color1
end

function color_chooser_boundingbox(obj)
  middle      = obj[:middle]  
  swatchsize  = obj[:swatchsize]
  border_size = obj[:border_size]
  model       = obj[:model]
  verts       = COLOR_QUAD[1]
  minv = Vec3(model*Vec4(minimum(verts)...,0f0))
  maxv = Vec3(model*Vec4(maximum(verts)...,0f0))
  AABB(minv,maxv)
end
end # local begin color chooser