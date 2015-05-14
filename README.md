# GLVisualize

[![Build Status](https://travis-ci.org/SimonDanisch/GLVisualize.jl.svg?branch=master)](https://travis-ci.org/SimonDanisch/GLVisualize.jl)


![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/vectorfield.jpg?raw=true) |  ![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/vectorfield.jpg?raw=true)
:-------------------------:|:-------------------------:
![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/vectorfield.jpg?raw=true)  |  ![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/vectorfield.jpg?raw=true)





This is the successor of GLPlot, and will soon be the core of it.
Right now it relies on a mixture of packages not in METADATA and different branches in these packages, so installation is a little tricky. 
But here is a script adding the packages and checking out the correct branches:
```Julia
Pkg.clone("https://github.com/JuliaGL/GLVisualize.jl.git")

Pkg.add("GLWindow")
Pkg.checkout("GLWindow", "julia04")

Pkg.add("GLAbstraction")
Pkg.checkout("GLAbstraction", "julia04")

Pkg.add("ModernGL")
Pkg.checkout("ModernGL", "master")

Pkg.clone("https://github.com/SimonDanisch/FixedSizeArrays.jl.git")
Pkg.checkout("FixedSizeArrays", "master")

Pkg.clone("https://github.com/JuliaGeometry/GeometryTypes.jl.git")
Pkg.checkout("GeometryTypes", "master")

Pkg.clone("https://github.com/SimonDanisch/ColorTypes.jl.git")
Pkg.checkout("ColorTypes", "master")

Pkg.add("Reactive")
Pkg.checkout("Reactive", "master")
Pkg.add("GLFW")
Pkg.checkout("GLFW", "julia04")

Pkg.add("Compat")
Pkg.checkout("Compat", "master")

Pkg.clone("https://github.com/JuliaIO/ImageIO.jl.git")
Pkg.checkout("ImageIO", "master")

Pkg.clone("https://github.com/JuliaIO/ImageMagick.jl.git")
Pkg.checkout("ImageMagick", "master")
Pkg.build("ImageMagick")

Pkg.clone("https://github.com/JuliaIO/WavefrontObj.jl.git")
Pkg.checkout("WavefrontObj", "master")


Pkg.clone("https://github.com/JuliaIO/FileIO.jl.git")
Pkg.checkout("FileIO", "master")

Pkg.clone("https://github.com/JuliaIO/MeshIO.jl.git")
Pkg.checkout("MeshIO", "master")

Pkg.add("Meshes")
Pkg.checkout("Meshes", "meshes2.0")

Pkg.clone("https://github.com/JuliaGPU/AbstractGPUArray.git")
Pkg.checkout("AbstractGPUArray", "master")

```
