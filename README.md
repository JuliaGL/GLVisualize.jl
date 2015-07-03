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
But here is a script adding the packages and checking out the correct branches.
Run it two times, because packages fail as they have unregistered packages in their require file.

```Julia
Pkg.clone("https://github.com/SimonDanisch/FixedSizeArrays.jl.git")
Pkg.checkout("FixedSizeArrays", "master")

Pkg.clone("https://github.com/JuliaGeometry/GeometryTypes.jl.git")
Pkg.checkout("GeometryTypes", "master")

Pkg.clone("https://github.com/SimonDanisch/ColorTypes.jl.git")
Pkg.checkout("ColorTypes", "master")


Pkg.clone("https://github.com/JuliaIO/FileIO.jl.git")
Pkg.checkout("FileIO", "master")


Pkg.clone("https://github.com/JuliaIO/MeshIO.jl.git")
Pkg.checkout("MeshIO", "master")

Pkg.add("Meshes")
Pkg.checkout("Meshes", "meshes2.0")

Pkg.clone("https://github.com/jhasse/FreeType.jl")
Pkg.checkout("FreeType", "master")


Pkg.clone("https://github.com/JuliaGPU/AbstractGPUArray.jl.git")
Pkg.checkout("AbstractGPUArray", "master")


Pkg.clone("https://github.com/SimonDanisch/FreeTypeAbstraction.jl")
Pkg.checkout("FreeTypeAbstraction", "master")

Pkg.clone("https://github.com/JuliaGeometry/Packing.jl.git")
Pkg.checkout("Packing", "master")

Pkg.clone("https://github.com/JuliaIO/ImageMagick.jl.git")
Pkg.checkout("ImageMagick", "master")
Pkg.build("ImageMagick")

Pkg.clone("https://github.com/JuliaIO/ImageIO.jl.git")
Pkg.checkout("ImageIO", "master")


Pkg.clone("https://github.com/JuliaIO/WavefrontObj.jl.git")
Pkg.checkout("WavefrontObj", "master")


Pkg.add("Reactive")
Pkg.checkout("Reactive", "master")
Pkg.add("GLFW")
Pkg.checkout("GLFW", "julia04")

Pkg.add("Compat")
Pkg.checkout("Compat", "master")

Pkg.add("VideoIO")
Pkg.checkout("VideoIO")
Pkg.build("VideoIO")

Pkg.add("GLWindow")
Pkg.checkout("GLWindow")
Pkg.checkout("GLWindow", "screen_rebuild")


Pkg.add("GLAbstraction")
Pkg.checkout("GLAbstraction", "julia04")

Pkg.add("ModernGL")
Pkg.checkout("ModernGL", "master")

Pkg.clone("https://github.com/JuliaGL/GLVisualize.jl.git")

```
