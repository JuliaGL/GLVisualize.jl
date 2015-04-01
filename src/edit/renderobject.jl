
function edit(style::Style, dict::Dict, customization::Dict{Symbol,Any})
  screen         = customization[:screen]
  yposition      = float32(screen.area.value.h)

  glypharray     = Array(Romeo.GLGlyph{Uint16}, 0)
  visualizations = RenderObject[]
  xgap = 60f0
  ygap = 20f0
  lineheight = 24f0
  currentline = 0
  aabb = AABB(Vec3(0), Vec3(0))
  i = 0
  for (name,value) in dict
    if method_exists(edit, (typeof(value),))
        currentline       += int(abs(aabb.max[2]-aabb.min[2])/lineheight) + i
        yposition         -= lineheight*2
        i = 3
        append!(glypharray, Romeo.GLGlyph{Uint16}[Romeo.GLGlyph(c, currentline, k, 0) for (k,c) in enumerate(string(name)*":")])
        visual, signal     = Romeo.edit(value, style, screen=screen)
        aabb               = visual.boundingbox(visual)

        translatm          = translationmatrix(Vec3(xgap - aabb.min[1], yposition - aabb.max[2], 0))
        visual[:model]     = translatm * visual[:model]
        dict[name]         = signal
        yposition          -= abs(aabb.max[2]-aabb.min[2]) + lineheight
        push!(visualizations, visual)
    end
  end
  labels = visualize(glypharray, screen=screen, color=rgba(0.19, 0.70,0.88,1.0), model=translationmatrix(Vec3(30, float32(screen.area.value.h), 0)))
  push!(visualizations, labels)
  visualizations
end
function edit(style::Style, obj::RenderObject, customization::Dict{Symbol,Any})
  edit(style, obj.uniforms, customization)
end


