Build status (Linux x86-64):
[![Build Status](https://ci.maleadt.net/buildbot/julia/png?builder=GLVisualize.jl:%20Julia%200.5%20(x86-64))](https://ci.maleadt.net/buildbot/julia/builders/GLVisualize.jl%3A%20Julia%200.5%20%28x86-64%29)

[![Coverage Status](https://coveralls.io/repos/github/JuliaGL/GLVisualize.jl/badge.svg?branch=HEAD)](https://coveralls.io/github/JuliaGL/GLVisualize.jl?branch=HEAD)


# GLVisualize

GLVisualize is an interactive 2D/3D visualization library completely written in OpenGL and Julia.
Its focus is on performance and allowing to display animations/interactions as smooth as possible.

#### Installation of GLVisualize
You need OpenGL 3.3, which should be available on most computers nowadays.
If you get an error like [this](https://github.com/JuliaGL/GLVisualize.jl/issues/129), please try updating your system/video driver.

Please run:
```Julia
Pkg.add("GLVisualize")
Pkg.test("GLVisualize")
```

Running the tests will walk you through all examples.
I made a recording of me giving a descriptions for every example:

[![glvisualize_tests](https://cloud.githubusercontent.com/assets/1010467/20456657/234e63dc-ae7b-11e6-9beb-fe49ea064aa8.png)](https://www.youtube.com/watch?v=WYX31vIkrd4&t=6s)


#### GLVisualize can be used as a backend for [Plots.jl](https://github.com/tbreloff/Plots.jl/)

Plot examples created with Plots and GLVisualize as a backend:

![plots](https://cloud.githubusercontent.com/assets/1010467/18788252/7246cff8-81a6-11e6-9a48-18d63e11fb25.gif)

Support for hovers and unicode:

![hover](https://cloud.githubusercontent.com/assets/1010467/18787764/7fc2c0b2-81a4-11e6-983d-8f73527f9293.gif)

Image marker type and hover:

[<img src="https://cloud.githubusercontent.com/assets/1010467/18789986/5caf3a34-81ad-11e6-8c58-d0a4b40ccce3.png" width="489">](https://vimeo.com/181942008 "Image Cloud")

#### [GLPlot.jl](https://github.com/SimonDanisch/GLPlot.jl), a GUI for plotting with GLVisualize
GLPlot allows you to interact with your plots and create GUI elements.

![lorenz attractor](https://cloud.githubusercontent.com/assets/1010467/18789098/f3fe7962-81a9-11e6-8305-8ffe9d4e6921.gif)

#### Hybrid GLPlot, Plots.jl

These examples use the lower level API of GLVisualize+GLPlot to allow interactions that would not be possible with Plots.jl alone.
It is planned to integrate this more nicely with the higher level interface in Plots.jl.

[<img src="https://cloud.githubusercontent.com/assets/1010467/18790024/7d5f4a58-81ad-11e6-9535-e2408bbea679.png" width="489">](https://vimeo.com/180307247 "Volume Plot")

[<img src="https://cloud.githubusercontent.com/assets/1010467/18790072/a888fde6-81ad-11e6-829a-f0210711584d.png" width="489">](https://vimeo.com/181694236 "Surface")

[<img src="https://cloud.githubusercontent.com/assets/1010467/18789938/284fc0f6-81ad-11e6-8497-e14ac65fceb4.png" width="489">](https://vimeo.com/183115490 "Image filtering")

#### Demo of GPU computing and visualization of the GPU object with GLVisualize
GLVisualize is GPU accelerated and we can use this fact to display computations run on the GPU as efficient as possible.
This is a demo using the packages [CUDAnative](https://github.com/JuliaGPU/CUDAnative.jl) and [GPUArrays](https://github.com/JuliaGPU/GPUArrays.jl) to run Julia code on the GPU and visualize the result.
Note that the CPU version takes around 60 seconds for every iteration. GPU acceleration brought this down to interactive speeds at around 0.12s per iteration!

[<img src="https://cloud.githubusercontent.com/assets/1010467/18793533/79b04714-81bb-11e6-9fa0-ed273888b7cf.png" width="489">](https://vimeo.com/184020541)


# Documentation


Please visit [glvisualize.com](http://www.glvisualize.com/) .
Example code on the website is out of date, pleaser refer to [examples folder](https://github.com/JuliaGL/GLVisualize.jl/tree/master/examples) to get the newest versions.


Known problems:
- boundingboxes are not always correct
- On Mac OS, you need to make sure that Homebrew.jl works correctly, which was not the case on some tested machines (needed to checkout master and then rebuild)
- GLFW needs `cmake` and `xorg-dev` `libglu1-mesa-dev` on linux (can be installed via `sudo apt-get install xorg-dev libglu1-mesa-dev`).


Try `Pkg.test("GLVisualize")` to see if things work! If things are working, you should see (after some delay for compilation) an animation pop up in a window with a spiral of cubes moving over a background of several other images and visualizations.
Close the window when you tire of watching it, and you should see a "tests passed" message.
