using GLVisualize, GeometryTypes, GLAbstraction, Reactive

particle_data2D(i, N) = Point2{Float32}[rand(Point2{Float32}, -1000f0:eps(Float32):1000f0) for x=1:N]

view(visualize(Point2{Float32}[Point2{Float32}(0)], scale=lift(Vec2, GLVisualize.ROOT_SCREEN.inputs[:framebuffer_size]), technique=:square))

renderloop()
