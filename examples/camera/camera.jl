using GLVisualize, GLAbstraction, FileIO, GeometryTypes, Reactive, GLWindow, Colors

if !isdefined(:runtests)
    window = glscreen()
    timesignal = bounce(linspace(0f0,1f0,360))
end

description = """
This example shows how to set up a custom camera,
animate it and display it in a second screen. The first screen
allows you to look at the camera in the scene.
"""

"""
functions to halve some rectangle
"""
xhalf(r)  = SimpleRectangle(r.x, r.y, r.w÷2, r.h)
xhalf2(r) = SimpleRectangle(r.w÷2, r.y, r.w÷2, r.h)

"""
Makes a spiral
"""
function spiral(i, start_radius, offset)
	Point3f0(sin(i), cos(i), i/10f0) * (start_radius + ((i/2pi)*offset))
end
# 2D particles
curve_data(i, N) = Point3f0[spiral(i+x/20f0, 1, (i/20)+1) for x=1:N]
# create a spiraling camera path
const camera_path  = curve_data(1f0, 360)

area_a, area_b = x_partition(window.area, 50)
# create first screen for the camera
camera_screen = Screen(
	window, name=:camera_screen,
	area = area_a
)
# create second screen to _view the scene
scene_screen = Screen(
	window, name=:scene_screen,
	area = area_b
)

# create an camera eyeposition signal, which follows the path
eyeposition = map(timesignal) do t
    len = length(camera_path)
    index = round(Int, (t*(len-1))+1) # mod1, just to be on the save side
    Vec3f0(camera_path[index])
end

# create the camera lookat and up vector
lookatposition = Signal(Vec3f0(0))
upvector = Signal(Vec3f0(0,0,1))

# create a camera from these
cam = PerspectiveCamera(camera_screen.area, eyeposition, lookatposition, upvector)

"""
Simple visualization of a camera
"""
function showcam(cam::PerspectiveCamera)
    lookvec, posvec, upvec = map(f-> getfield(cam, f), (:lookat, :eyeposition, :up))
    positions = map((a,b) -> Point3f0[a,b], lookvec, posvec)
    lines = map(lookvec, posvec, upvec) do l,p,u
        dir = p-l
        right = normalize(cross(dir,u))
        Point3f0[
            l,p,
            p, p+u,
            p, p+right
        ]
    end
    colors = RGBA{Float32}[
        RGBA{Float32}(1,0,0,1),
        RGBA{Float32}(1,0,0,1),

        RGBA{Float32}(0,1,0,1),
        RGBA{Float32}(0,1,0,1),

        RGBA{Float32}(0,0,1,1),
        RGBA{Float32}(0,0,1,1),
    ]
    poses = visualize((Sphere(Point3f0(0), 0.05f0), positions))
    lines = visualize(lines, :linesegment, color=colors)
    Context(poses, lines)
end

# add the camera to the camera screen as the perspective camera
camera_screen.cameras[:perspective] = cam

# something to look at
cat = visualize(GLNormalMesh(loadasset("cat.obj")))

# visualize the camera path
camera_points = visualize(
    (Circle(Point2f0(0), 0.03f0), camera_path),
    color=RGBA{Float32}((Vec3f0(0,206,209)/256)..., 1f0), billboard=true
)

camera_path_line = visualize(camera_path, :lines)



# _view everything on the appropriate screen.
# we need to copy the cat, because _view inserts the camera into the
# actual render object. this is sub optimal and will get changed!
# Note, that this is a shallow copy, so the actual data won't be copied,
# just the data structure that holds the camera
_view(copy(cat), camera_screen, camera=:perspective)
_view(copy(cat), scene_screen, camera=:perspective)
_view(showcam(cam), scene_screen, camera=:perspective)
_view(camera_points, scene_screen, camera=:perspective)
_view(camera_path_line, scene_screen, camera=:perspective)

if !isdefined(:runtests)
	renderloop(window)
end
