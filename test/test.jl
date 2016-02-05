using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive
using GLWindow, FileIO, ImageMagick, ModernGL

"""
This is the GLViualize Test suite.
It tests all examples in the example folder and has the options to create
docs from the examples.
"""
module Test
    window = glscreen(debugging=true)
    const runtests  = true
    const make_docs = true
    function create_video(frames, path, name)
        for elem in frames
            save(joinpath(path, "$name$frame.png"), elem, true)
        end
        println("created $name's png sequence successfully!")
        cd(path)
        run(pipeline(`png2yuv -I p -f 30 -b 1 -n $nframes -j $name%d.png`, "$name.yuv"))
        run(
            `vpxenc --good --cpu-used=0 --auto-alt-ref=1
            --lag-in-frames=16 --end-usage=vbr --passes=2 --threads=2
            --target-bitrate=3500 -o $name.webm $name.yuv`
        )
        println("created $name's video sequence successfully!")
    end
    function create_docs(name)
        source_code = readall(open(Pkg.dir("GLVisualize", "examples", name)))
        path = videopath(name)
        """
        <h1>$(ucfirst(name))</h1>
        <video  width="480" height="300" autoplay loop>
          <source src="$path">
              Your browser does not support the video tag.
        </video>

        {% highlight julia %}
        $(source_code)
        {% endhighlight %}
        """
    end
    function record_test(window, video_folder)
        nframes = 360
        frames = []
        for frame in 1:nframes
            push!(time, frame/nframes)
            yield()
            GLWindow.renderloop_inner(window)
            buffer = screenbuffer(window)
            push!(frames, buffer)
        end
        frames
    end
    function record_test_interactive(window, video_folder)
        nframes = 360
        frames = []
        while isopen(window)
            push!(time, frame/nframes)
            yield()
            GLWindow.renderloop_inner(window)
            push!(frames, screenbuffer(window))
        end
        frames
    end

end

macro test_and_record(name)
    modulename = symbol("Test$(ucfirst(name))")
    esc(quote
        module $modulename
        using .Test
        const runtests = true
        const time     = Signal(0.0)

        include(joinpath("..", "examples", "$name.jl"))
        if make_docs
            mktempdir("$name") do videofolder
                if isdefined(:isinteractive)
                    frames = record_test_interactive(window, videofolder)
                else
                    frames = record_test(window, videofolder)
                end
                create_video(frames, video_folder, name)
                create_docs(name)
            end
        end
    end)
end
