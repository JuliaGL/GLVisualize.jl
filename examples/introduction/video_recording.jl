using Colors, GLVisualize, GLAbstraction, GLWindow

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
    ENV["CI_REPORT_DIR"] * "videorecord"
else
    homedir()
end

name = ""
isdir(path) || mkdir(path)
while true # for some reason, folder retured by mktempdir isn't usable -.-
    name = path * "/$(randstring()).mkv"
    isfile(name) || break
end

# create a stream to which we can add frames
io = GLVisualize.create_video_stream(name, window)
for i=1:10 # record 10 frames
    # do something
    GLAbstraction.set_arg!(kitty, :color, RGBA{Float32}(1, 0, 1-(i/10), i/10))
    #render current frame
    # if you call @async renderloop(window) you can replace this part with yield
    GLWindow.render_frame(window)
    GLWindow.swapbuffers(window)
    GLWindow.reactive_run_till_now()

    # add the frame from the current window
    GLVisualize.add_frame!(io)
end
# closing the stream will trigger writing the video!
close(io.io)

# clean up, only when we're not recording this!
if !haskey(ENV, "CI_REPORT_DIR")
    rm(name)
end
