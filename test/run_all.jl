include("ExampleRunner.jl")
using ExampleRunner
screencast_folder = joinpath(homedir(), "glvisualize_screencast")
!isdir(screencast_folder) && mkdir(screencast_folder)
config = RunnerConfig(
    number_of_frames = 360,
    interactive_time = 0.1,
    record=false
)

ExampleRunner.run(config)
for (k, v) in config.failed_examples
    println(k)
end

x = addprocs(1)

@everywhere using GLVisualize, GeometryTypes, Images, Colors, FileIO, GLAbstraction, GLWindow

gl_api = fetch(@spawnat 2 begin
    w=glscreen()
    @async renderloop(w)
    nothing
end) # spawn gl

function xy_data(x,y,i, N)
    x = sqrt(x) / sin(x)
    x = cos(((x/N)-0.5f0)*i)
    y = sin(((y/N)-0.5f0)*i) / 2f0
    r = sqrt(x*x + y*y)
    Point2f0(sin(r), x/r)
end

surf(i, N) = Point3f0[Point3f0(x, y, z)./(N/i) for x=1:N for y=1:N, z=1:N]
@time points = surf(1f0, 50)

objr = @spawnat 2 begin
    empty!(GLVisualize.current_screen())
    robj = visualize((Circle, points), scale=Vec2f0(0.01), billboard=true)
    _view(robj, camera=:perspective)
    robj
end
f(RGBA(1f0, 0f0,1f0,1f0))

@spawnat 2 begin
    set_arg!(fetch(objr), :position, points)
    nothing
end

for i=linspace(1f0, 60f0, 100)
    @time x = surf(i, 1000)
end

using GLAbstraction, GLWindow


w = Screen()
x = Texture(rand(Float32, 32,32))
open(homedir()*"/test.jls", "w") do io
    serialize(io, x)
end

t = open(homedir()*"/test.jls") do io
    deserialize(io)
end
gpu_data(t) == gpu_data(x)
