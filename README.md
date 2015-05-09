# GLVisualize

[![Build Status](https://travis-ci.org/SimonDanisch/GLVisualize.jl.svg?branch=master)](https://travis-ci.org/SimonDanisch/GLVisualize.jl)

This is the successor of GLPlot, and will soon be the core of it.
Right now it relies on a mixture of packages not in METADATA and different branches in these packages, so installation is a little tricky. But here is a script adding the packages and checking out the correct branches:
```Julia
Pkg.clone("https://github.com/JuliaGL/GLVisualize.jl.git")

!isa(Pkg.installed("GLWindow"), VersionNumber) && Pkg.add("GLWindow")
Pkg.checkout("GLWindow", "julia04")

!isa(Pkg.installed("GLAbstraction"), VersionNumber) && Pkg.add("GLAbstraction")
Pkg.checkout("GLAbstraction", "julia04")

!isa(Pkg.installed("ModernGL"), VersionNumber) && Pkg.add("ModernGL")
Pkg.checkout("ModernGL", "master")

!isa(Pkg.installed("FixedSizeArrays"), VersionNumber) && Pkg.clone("https://github.com/SimonDanisch/FixedSizeArrays.jl.git")
Pkg.checkout("FixedSizeArrays", "master")

!isa(Pkg.installed("GeometryTypes"), VersionNumber) && Pkg.clone("https://github.com/JuliaGeometry/GeometryTypes.jl.git")
Pkg.checkout("GeometryTypes", "master")

!isa(Pkg.installed("ColorTypes"), VersionNumber) && Pkg.clone("https://github.com/SimonDanisch/ColorTypes.jl.git")
Pkg.checkout("ColorTypes", "master")

!isa(Pkg.installed("Reactive"), VersionNumber) && Pkg.add("Reactive")
Pkg.checkout("Reactive", "master")

!isa(Pkg.installed("GLFW"), VersionNumber) && Pkg.add("GLFW")
Pkg.checkout("GLFW", "julia04")

!isa(Pkg.installed("Compat"), VersionNumber) && Pkg.add("Compat")
Pkg.checkout("Compat", "master")

!isa(Pkg.installed("ImageIO"), VersionNumber) && Pkg.clone("https://github.com/JuliaIO/ImageIO.jl.git")
Pkg.checkout("ImageIO", "master")


!isa(Pkg.installed("FileIO"), VersionNumber) && Pkg.clone("https://github.com/JuliaIO/FileIO.jl.git")
Pkg.checkout("FileIO", "master")

!isa(Pkg.installed("MeshIO"), VersionNumber) && Pkg.clone("https://github.com/JuliaIO/MeshIO.jl.git")
Pkg.checkout("MeshIO", "master")

!isa(Pkg.installed("Meshes"), VersionNumber) && Pkg.add("Meshes")
Pkg.checkout("Meshes", "meshes2.0")

!isa(Pkg.installed("AbstractGPUArray"), VersionNumber) && Pkg.clone("https://github.com/JuliaGPU/AbstractGPUArray.git")
Pkg.checkout("AbstractGPUArray", "master)
```
