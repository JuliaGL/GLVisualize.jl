using GLVisualize, GLWindow
screen, renderloop = Screen()

view(visualize(rand(Float32, 71,73)))
renderloop()