# GLVisualize

GLVisualize is an interactive 2D/3D visualization library completely written in OpenGL and Julia.

# Documentation


Please visit [glvisualize.com](http://www.glvisualize.com/)


# Installation


```Julia
Pkg.add("GLVisualize")
# on 0.5 you also need:
Pkg.checkout("Mustache")
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
- GLVisualize seems to be slow randomly. Please open an issue if Pkg.test("GLVisualize") runs slow, so that I can figure out if this is a general problem.
- boundingboxes are not always correct
- On Mac OS, you need to make sure that Homebrew.jl works correctly, which was not the case on some tested machines (needed to checkout master and then rebuild)
- GLFW needs `cmake` and `xorg-dev` `libglu1-mesa-dev` on linux (can be installed via `sudo apt-get install xorg-dev libglu1-mesa-dev`).
- VideoIO and FreeType seem to be also problematic on some platforms. There isn't a fix for all situations. If these package fail, try `Pkg.update();Pkg.build("FailedPackage")`.If this still fails, report an issue on Github!

Try `Pkg.test("GLVisualize")` to see if things work! If things are working, you should see (after some delay for compilation) an animation pop up in a window with a spiral of cubes moving over a background of several other images and visualizations.
Close the window when you tire of watching it, and you should see a "tests passed" message.
