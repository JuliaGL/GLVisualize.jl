using GLVisualize, FileIO, ModernGL, Colors, GLAbstraction, GeometryTypes

img = load(joinpath(homedir(), "Desktop", "backround.jpg"))
w = glscreen(resolution = reverse(size(img)))
@async renderloop(w)

_view(visualize(
    img,
    model = translationmatrix(Vec3f0(0, 0, -10000)) # move as far back as clip allows
), camera = :fixed_pixel)
_view(visualize(loadasset("cat.obj")))
