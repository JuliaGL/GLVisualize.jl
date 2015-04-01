if isdefined(Main, :PyPlot)
  begin
  wh = [500,500]
  f = PyPlot.gcf()
  const pyplotplot = visualize(Texture(ARGB{Ufixed8}, wh)) 
  function visualize(style::Style, plot::Gadfly.Plot, customizations)
      ram  = convert(Array{Uint8},f[:canvas][:tostring_argb]())
      pyplotplot[:image][1:end, 1:end] = reinterpret(ARGB{Ufixed8}, ram, f[:canvas][:get_width_height]())
  end
  end
end
if isdefined(Main, :Gadfly)
  using Cairo, FixedPointNumbers
  wh = [500,500]
  const surface = Cairo.CairoARGBSurface(zeros(Uint32, wh...))
  const cairocontext = CairoContext(surface)
  global gadflyplot  = 0
  visualize(plot::Main.Gadfly.Plot, style::Style=Style(:Default); customizations...) = visualize(style, plot, Dict{Symbol, Any}(customizations))
  function redrawplot(plot::Main.Gadfly.Plot)
    set_source_rgba(cairocontext, 1.0,1.0,1.0,1.0)
    paint(cairocontext)
    Main.Gadfly.draw(Main.Gadfly.PNG(surface),  Main.Gadfly.render(plot))
    
  end
  function visualize(style::Style, plot::Main.Gadfly.Plot, customizations)
    global gadflyplot
    gadflyplot == 0 && (gadflyplot = visualize(Texture(BGRA{Ufixed8}, wh), screen=customizations[:screen]))
    redrawplot(plot)
    gadflyplot[:image][1:end, 1:end] = mapslices(reverse, reinterpret(BGRA{Ufixed8}, surface.data),2)
    gadflyplot
  end
end
