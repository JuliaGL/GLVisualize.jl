# GLVisualize


|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/vectorfield.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_vectorfield.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/isosurface.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_isosurface.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/surface.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_surface.jl) |
| --- | --- | --- |
| [![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/volume.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_volume.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/obj.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_obj.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/particles2D.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_particles2D.jl) |
| --- | --- | --- |
| [![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/dots.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_dots.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/barplot.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_barplot.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/particles.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_particles.jl) |
| --- | --- | --- |
| [![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/arbitrary_surf.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_arbitrary_surface.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/image.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_image.jl)|[![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/sierpinski.jpg?raw=true)](https://github.com/JuliaGL/GLVisualize.jl/blob/master/test/test_sierpinski_mesh.jl) |
Please click on the examples to see the code, which produced the image.

This is basically the successor of GLPlot, and will soon be its new rendering core.
Right now it relies on a mixture of packages not in METADATA and different branches in these packages, so installation is a little tricky.
You should use a relatively new version of Julia 0.4.
Here is a script adding the packages and checking out the correct branches:
```Julia
Pkg.clone("https://github.com/JuliaIO/FileIO.jl.git")
Pkg.clone("https://github.com/JuliaIO/MeshIO.jl.git")
Pkg.clone("https://github.com/JuliaGeometry/Packing.jl.git")
Pkg.clone("https://github.com/JuliaIO/ImageMagick.jl.git")
Pkg.build("ImageMagick")
Pkg.clone("https://github.com/JuliaGL/GLVisualize.jl.git")
Pkg.checkout("Images", "sd/fileio")
Pkg.checkout("GeometryTypes")
Pkg.checkout("FixedSizeArrays")
Pkg.checkout("Meshes", "ntuples")
Pkg.checkout("ModernGL")
Pkg.checkout("GLWindow")
Pkg.checkout("GLAbstraction")
```
It should run without errors by now.
Known problems:
On Mac OS, you need to make sure that Homebrew.jl works correctly, which was not the case on the tested machines (needed to checkout master and then rebuild)
GLFW needs cmake and xorg-dev libglu1-mesa-dev on linux (can be installed via `sudo apt-get install xorg-dev libglu1-mesa-dev`).
VideIO and FreeType seem to be also problematic on some platforms. Haven't figured out a fix yet.
Try `Pkg.test("GLVisualize")` to see if things work!
