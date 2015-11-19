# GLVisualize



Please click on the examples to see the code, which produced the image.

This is basically the successor of GLPlot, and will soon be its new rendering core.

You should use a relatively new version of Julia 0.4.
Here is a script adding the packages and checking out the correct branches:

```Julia
Pkg.add("GLVisualize")
Pkg.checkout("Reactive")
Pkg.checkout("GLVisualize")
Pkg.checkout("GLAbstraction")
Pkg.checkout("GLWindow")
```

It should run without errors by now.

Known problems:

- On Mac OS, you need to make sure that Homebrew.jl works correctly, which was not the case on the tested machines (needed to checkout master and then rebuild)
- GLFW needs cmake and xorg-dev libglu1-mesa-dev on linux (can be installed via `sudo apt-get install xorg-dev libglu1-mesa-dev`).
- VideoIO and FreeType seem to be also problematic on some platforms. Haven't figured out a fix yet. If these package fail, try `Pk.update();Pkg.build("FailedPackage")`.If this still fails, report an issue on Github!


Try `Pkg.test("GLVisualize")` to see if things work! If things are working, you should see (after some delay for compilation) an animation pop up in a window with a spiral of cubes moving over a background of several other images and visualizations. Something like this:
![](https://github.com/JuliaGL/GLVisualize.jl/blob/master/docs/testimage.png?raw=true)
Close the window when you tire of watching it, and you should see a "tests passed" message.
