using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ModernGL


const randrange = -0.01f0:eps(Float32):0.01f0
start_point = Point3(0f0)
const robj1 = visualize(Point3{Float32}[(start_point += rand(Point3{Float32}, randrange)) for i=1:25000], :dots, 
	particle_color=RGBAU8[rgbaU8(1,0,0,1)], point_size=3f0)
start_point = Point3(0f0)
const robj2 = visualize(Point3{Float32}[(start_point += rand(Point3{Float32}, randrange)) for i=1:25000], :dots, 
	particle_color=RGBAU8[rgbaU8(1,1,0,1)], point_size=5f0)
start_point = Point3(0f0)
const robj3 = visualize(Point3{Float32}[(start_point += rand(Point3{Float32}, randrange)) for i=1:25000], :dots, particle_color=RGBAU8[rgbaU8(1,0,1,1)])
start_point = Point3(0f0)
const robj4 = visualize(Point3{Float32}[(start_point += rand(Point3{Float32}, randrange)) for i=1:25000], :dots, particle_color=RGBAU8[rgbaU8(0,0,1,0.1)], point_size=15f0)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj2)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj3)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj4)


renderloop()
