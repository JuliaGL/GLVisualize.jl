#`ffmpeg -i volume.webm -codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 4 -vf scale=-1:480 -codec:a libvorbis -b:a 128k volume2.webm`
# ffmpeg version
# ffmpeg -r 24 -pattern_type glob -i '*.png' -vcodec libx264 -crf 25  -pix_fmt yuv420p test.mp4

immutable VideoStream
    io
    buffer
    window
end

"""
returns a stream and a buffer that you can use to not allocate for new frames.
Use `add_frame!(stream, window, buffer)` to add new video frames to the stream.
"""
function create_video_stream(path, window)
    #codec = `-codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 8`
    tex = GLWindow.framebuffer(window).color
    res = size(tex)
    io, process = open(`ffmpeg -f rawvideo -pixel_format rgb24 -s:v $(res[1])x$(res[2]) -i pipe:0 -vf vflip -y $path`, "w")
    VideoStream(io, Matrix{RGB{N0f8}}(res), window) # tmp buffer
end

"""
Adds a video frame to a stream created with `create_video_stream`
"""
function add_frame!(io)
    #codec = `-codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 8`
    tex = GLWindow.framebuffer(io.window).color
    write(io.io, map(RGB{N0f8}, gpu_data(tex)))
end

"""
Converts a folder full of videos into a folder full of webm videos
"""
function webm_batchconvert(oldpath, newpath, scale = 0.5)
    for file in readdir(oldpath)
        isfile(file) || continue
        f = joinpath(oldpath, file)
        name, ext = splitext(file)
        ext != ".mkv" && continue
        out = joinpath(newpath, name * ".webm")
        run(`ffmpeg -i $f -c:v libvpx-vp9 -threads 16 -b:v 2000k -c:a libvorbis -threads 16 -vf scale=iw$("*")$scale:ih$("*")$scale -y $out`)
    end
end
