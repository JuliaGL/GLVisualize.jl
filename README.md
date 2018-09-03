**Build status**: [![](https://ci.maleadt.net/buildbot/julia/badge.svg?builder=GLVisualize.jl:%20Julia%200.6%20(x86-64)&badge=Julia%20v0.6)](https://ci.maleadt.net/buildbot/julia/builders/GLVisualize.jl%3A%20Julia%200.6%20%28x86-64%29)

**Code coverage**: [![Coverage Status](https://coveralls.io/repos/github/JuliaGL/GLVisualize.jl/badge.svg?branch=HEAD)](https://coveralls.io/github/JuliaGL/GLVisualize.jl?branch=HEAD)





# GLVisualize isn't under active development anymore, since all it's features + code have been added to Makie:
https://github.com/JuliaPlots/Makie.jl







## GLVisualize

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

#### Demo of GPU computing and visualization of the GPU object with GLVisualize
GLVisualize is GPU accelerated and we can use this fact to display computations run on the GPU as efficient as possible.
This is a demo using the packages [CUDAnative](https://github.com/JuliaGPU/CUDAnative.jl) and [GPUArrays](https://github.com/JuliaGPU/GPUArrays.jl) to run Julia code on the GPU and visualize the result.
Note that the CPU version takes around 60 seconds for every iteration. GPU acceleration brought this down to interactive speeds at around 0.12s per iteration!

[<img src="https://cloud.githubusercontent.com/assets/1010467/18793533/79b04714-81bb-11e6-9fa0-ed273888b7cf.png" width="489">](https://vimeo.com/184020541)


# Documentation


Please visit [the documentation](http://simondanisch.github.io/) .
Example code on the website is out of date, pleaser refer to [examples folder](https://github.com/JuliaGL/GLVisualize.jl/tree/master/examples) to get the newest versions.


Known problems:
- On Mac OS, you need to make sure that Homebrew.jl works correctly, which was not the case on some tested machines (needed to checkout master and then rebuild)
- GLFW needs `cmake` and `xorg-dev` `libglu1-mesa-dev` on linux (can be installed via `sudo apt-get install xorg-dev libglu1-mesa-dev`).


Try `Pkg.test("GLVisualize")` to see if things work! If things are working, you should see (after some delay for compilation) an animation pop up in a window with a spiral of cubes moving over a background of several other images and visualizations.
Close the window when you tire of watching it, and you should see a "tests passed" message.
