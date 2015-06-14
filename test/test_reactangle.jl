using GLVisualize, GeometryTypes, GLAbstraction, Reactive, ColorTypes


a = Input(Rectangle{Int64}(20,20,900,1000))
b = Input(Rectangle{Int64}(960,0,960,1280))
view(visualize(a, color=RGBA(1f0,0f0,1f0,0.5f0)))
#view(visualize(b, color=RGBA(0f0,0f0,1f0,1f0)))

renderloop()
