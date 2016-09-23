# GLVisualize

GLVisualize is an interactive 2D/3D visualization library completely written in OpenGL and Julia.

#### GLVisualize can be used as a backend for [Plots.jl](https://github.com/tbreloff/Plots.jl/)

Plot examples created with Plots and GLVisualize as a backend:

![plots](https://cloud.githubusercontent.com/assets/1010467/18788252/7246cff8-81a6-11e6-9a48-18d63e11fb25.gif)

Support for hovers and unicode:

![hover](https://cloud.githubusercontent.com/assets/1010467/18787764/7fc2c0b2-81a4-11e6-983d-8f73527f9293.gif)


#### [GLPlot.jl](https://github.com/SimonDanisch/GLPlot.jl), a GUI for plotting with GLVisualize
GLPlot allows you to interact with your plots and create GUI elements.

![lorenz attractor](https://cloud.githubusercontent.com/assets/1010467/18789098/f3fe7962-81a9-11e6-8305-8ffe9d4e6921.gif)

#### Hybrid GLPlot, Plots.jl

Plots.jl is not fully integrated with GLVisualize yet.
E.g. heavy animations can't be done in a fast way yet.
These are a few demos that work around this restriction by accessing the lower level API of Plots and GLVisualize.
They show what we can do as soon as GLPlot is better integrated with Plots.jl.

[<img src="https://cloud.githubusercontent.com/assets/1010467/18790024/7d5f4a58-81ad-11e6-9535-e2408bbea679.png" width="489">](https://vimeo.com/180307247 "Volume Plot")

[<img src="https://cloud.githubusercontent.com/assets/1010467/18789986/5caf3a34-81ad-11e6-8c58-d0a4b40ccce3.png" width="489">](https://vimeo.com/181942008 "Image Cloud")

[<img src="https://cloud.githubusercontent.com/assets/1010467/18790072/a888fde6-81ad-11e6-829a-f0210711584d.png" width="489">](https://vimeo.com/181694236 "Surface")

[<img src="https://cloud.githubusercontent.com/assets/1010467/18789938/284fc0f6-81ad-11e6-8497-e14ac65fceb4.png" width="489">](https://vimeo.com/183115490 "Image filtering")

#### Demo of GPU computing and visualization of the GPU object with GLVisualize
GLVisualize GPU accelerated and we can use this fact to display computations run on the GPU as efficient as possible.
This a demo using the unreleased packages [CUDAnative](https://github.com/JuliaGPU/CUDAnative.jl) and [GPUArrays](https://github.com/JuliaGPU/GPUArrays.jl).
The Julia code is run directly on the GPU.
[<img src="https://cloud.githubusercontent.com/assets/1010467/18793533/79b04714-81bb-11e6-9fa0-ed273888b7cf.png" width="489">](https://vimeo.com/184020541)


# Documentation


Please visit [glvisualize.com](http://www.glvisualize.com/)


# Installation


```Julia
Pkg.add("GLVisualize")
```
If you like to live on the edge, you can checkout master as well:
```Julia
Pkg.checkout("GLVisualize")
Pkg.checkout("GLAbstraction")
Pkg.checkout("GeometryTypes")
Pkg.checkout("GLWindow")
Pkg.checkout("Reactive")
```

Known problems:
- boundingboxes are not always correct
- On Mac OS, you need to make sure that Homebrew.jl works correctly, which was not the case on some tested machines (needed to checkout master and then rebuild)
- GLFW needs `cmake` and `xorg-dev` `libglu1-mesa-dev` on linux (can be installed via `sudo apt-get install xorg-dev libglu1-mesa-dev`).


Try `Pkg.test("GLVisualize")` to see if things work! If things are working, you should see (after some delay for compilation) an animation pop up in a window with a spiral of cubes moving over a background of several other images and visualizations.
Close the window when you tire of watching it, and you should see a "tests passed" message.
