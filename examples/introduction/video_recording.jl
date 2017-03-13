using Colors, GLVisualize, GLAbstraction, GL

if !isdefined(:runtests)
    window = glscreen()
end
description = """
Example of how to record a video from GLVisualize
"""
kitty = visualize(loadasset("cat.obj"))
_view(kitty, window)

# save video to report dir, or in some tmp dir we'll delete later
path = if haskey(ENV, "CI_REPORT_DIR")
    ENV["CI_REPORT_DIR"]
else
    mktempdir()
end

name = path * "/test.mkv"
io, buffer = GLVisualize.create_video_stream(name, window)
println("io created")
for i=1:10 # record 10 frames
    # do something
    GLAbstraction.set_arg!(kitty, :color, RGBA{Float32}(1, 0, 1-(i/10), i/10))
    #render current frame
    # if you call @async renderloop(window) you can replace this part with yield
    GLWindow.render_frame(window)
    GLWindow.swapbuffers(window)
    GLWindow.poll_reactive()

    # add the frame from the current window
    GLVisualize.add_frame!(io, window, buffer)
end
println("recording done!")
close(io)

# clean up, only when we're not recording this!
if !haskey(ENV, "CI_REPORT_DIR")
    rm(path, force = true, recursive = true)
end

if !isdefined(:runtests)
    renderloop(window)
end
