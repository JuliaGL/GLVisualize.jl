using FileIO, ImageIO, GLVisualize, ColorTypes, FixedPointNumbers, GLAbstraction
const img = read(file"feelsgood.png").data
#img2 = convert(GrayAlpha{Ufixed8}, img)
robj = visualize(Texture(img, minfilter=:nearest))
println(robj[:image])
view(robj)

renderloop()

