using GLVisualize, GLAbstraction, GeometryTypes, Reactive, ColorTypes, ModernGL
w,r = glscreen()
glClearColor(1,1,1,1)

text = visualize("utf8_exa|mp>le_text")

view(text)

r()

