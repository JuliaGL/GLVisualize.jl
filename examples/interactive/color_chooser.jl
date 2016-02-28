using GLVisualize, Colors, GeometryTypes, Reactive
color_s = Signal(RGBA{Float32}(1,0,0,1))
window = glscreen()
color_s, color_v = vizzedit(color_s, window)

view(color_v, window, camera=:fixed_pixel)

renderloop(window)
