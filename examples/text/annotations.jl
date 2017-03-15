using GLVisualize, GeometryTypes, Colors, GLAbstraction, Reactive, Images, ModernGL
<<<<<<< HEAD
import GLVisualize: mm, calc_position, glyph_bearing!, glyph_uv_width!, glyph_scale!

window = glscreen()
=======
import GLVisualize: mm, annotated_text

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end
>>>>>>> master

description = """
Example of showing animated annotations over an image stream
"""

<<<<<<< HEAD
# Displayes an array of points with text labels. This should get moved into GLVisualize!
function annotated_text(
        points, labels_s;
        color = RGBA(0f0,0f0,0f0,1f0),
        scale = 5mm,
        base_offset = Point2f0(scale / 2)
    )
    # make this work for Signal(points) as well as constant points
    points_s = isa(points, Signal) ? points : Signal(points)
    font, atlas = GLVisualize.defaultfont(), GLVisualize.get_texture_atlas()
    # to display a text particle system, one needs
    # 1, glyph segmentation_centroids, offset to the bottom, position in the texture atlas
    # and the scale of the glyph. Then for bg labels, we also save a width
    v0 = (Point2f0[], Point2f0[], Vec4f0[], Vec2f0[], Vec2f0[])
    text = map(points_s) do points
        labels = value(labels_s)
        if length(labels) != length(points)
            error("""
                Colors, labels and points must have the same length! Found:
                Points: $(length(points)), labels: $(length(labels))""")
        end
        n = mapreduce(length, +, labels)
        rpoints, offsets, uv_widths, scales, widths = v0
        if length(labels) != length(widths)
            resize!(widths, length(labels))
        end
        if n != length(rpoints) # only resize if size changed
            resize!(rpoints, n); resize!(offsets, n)
            resize!(uv_widths, n); resize!(scales, n)
        end
        idx = 1
        # glyph height of a long glyph
        glyph_height = glyph_scale!(atlas, '|', font, scale)[2]
        for (i, (start_pos, label)) in enumerate(zip(points, labels))
            last_pos = start_pos .+ base_offset
            for c in label # calculate segmentation_centroids for each character/glyph
                rpoints[idx] = last_pos
                last_pos = calc_position(last_pos, start_pos, atlas, c, font, scale)
                offsets[idx] = glyph_bearing!(atlas, c, font, scale)
                uv_widths[idx] = glyph_uv_width!(atlas, c, font)
                scales[idx] = glyph_scale!(atlas, c, font, scale)
                idx += 1
            end
            # calculate label lengths + extra width
            widths[i] = Vec2f0(last_pos[1] - start_pos[1] + 1mm, glyph_height + 1mm)
        end
        rpoints, offsets, uv_widths, scales, widths
    end
    viz = visualize(
        (DISTANCEFIELD, map(x->x[1], text)), # render segmentation_centroids as a distance field particle type
        offset = map(x->x[2], text),
        uv_offset_width = map(x->x[3], text),
        scale = map(x->x[4], text),
        color = color,
        # drop down to low level opengl, to always render over image! (there should be a better API for this)
        prerender = () -> begin
            glDisable(GL_DEPTH_TEST)
            glDepthMask(GL_TRUE)
            glDisable(GL_CULL_FACE)
            enabletransparency()
        end,
        distancefield = atlas.images
    )
    viz, map(last, text) # return viz and widths
end


# _view and visualize it!
# you could also pass segmentation_centroids as a keyword argument or make
# the scale/rotation per glyph by supplying a Vector of them.
N = 20
segmentation_centroids = Signal(rand(Point2f0, N) .* 1000f0)
label_str = Signal([string(i) for i=1:N])

labels, widths = annotated_text(segmentation_centroids, label_str)
fbuffer = rand(Gray{N0f8}, 1200, 1600)
=======
N = 20
positions = foldp(rand(Point2f0, N) .* 500f0, timesignal) do v0, t
    map!(v0) do p
        map(p .+ (rand(Point2f0) .- 0.5f0) .* 10f0) do pi
            clamp(pi, 0f0, 500f0) # restrict to image
        end
    end
end
base = [string(i) for i=1:N]
label_str = foldp(copy(base), timesignal) do v0, t
    map!(v0, base) do baselabel
        string(baselabel, ' ', round(t, 3))
    end
end

labels, widths = annotated_text(positions, label_str)
fbuffer = foldp(rand(RGB{N0f8}, 500, 500), timesignal) do v0, t
    map!(v0) do v
        RGB(v.r > 0.5 ? sin(v.r) : cos(v.r), (sin(t) + 1) / 2, 0.7) # yeah, real creative..
    end
end
>>>>>>> master
frame_viz = visualize(fbuffer)

# instead of circle you can also use unicode charactes (e.g. '+')
position_viz = visualize(
<<<<<<< HEAD
    (Circle{Float32}(0, 1.5mm), segmentation_centroids),
    color = RGBA(1f0, 0f0, 0f0, 0.6f0)
)

gpu_position = position_viz.children[][:position]
bg_viz = visualize(
    (ROUNDED_RECTANGLE, segmentation_centroids),
=======
    (Circle{Float32}(0, 1.5mm), positions),
    color = RGBA(1f0, 0f0, 0f0, 0.6f0)
)
gpu_position = position_viz.children[][:position]
bg_viz = visualize(
    (ROUNDED_RECTANGLE, gpu_position),
>>>>>>> master
    scale = widths,
    # you can give each label a color (random looks terrible, which is why whe use just white instead)
    # color = RGBA{Float32}[rand(RGB) for i = 1:N],
    color = RGBA(1f0, 1f0, 1f0, 0.6f0),
    offset = Vec2f0(1.0mm)
)
_view(frame_viz, window)
_view(bg_viz, window)
_view(labels, window)
_view(position_viz, window)
<<<<<<< HEAD
# N0f8, like UInt8, but between 0-1 to make for more realistic gray values

# For optimal performance, we need to get the gpu handle of the image
# need to acces children for that, since visualize always returns a tree structure,
# which contains just one element in our case
gpu_image = frame_viz.children[1][:image]
center!(window, :orthographic_pixel) # center orthographic_pixel camera to what we just visualized
Reactive.stop() # stop reactives event loop, we poll ourselves!
idx = 0
while isopen(window)

    # update position values inplace
    map!(value(segmentation_centroids)) do p
        p .+ (rand(Point2f0) .- 0.5f0) .* 10f0
    end
    # # push! to signal to update visualization
    push!(segmentation_centroids, value(segmentation_centroids))
    
    # update text! (ZOOP!!!)
    push!(label_str, [string(i + idx) for i=1:N])
    # you could also update the labels here!, if you put them in a signal

    # update frame buffer inplace with new "camera capture"
    map!(fbuffer) do v
        v > 0.5 ? sin(v) : cos(v) # yeah, real creative..
    end
    # UPDATE FRAME FROM CAMERA!!!!
    gpu_image[1:end, 1:end] = fbuffer # update data on GPU (ZING!!!)

    # do the rendering
    GLWindow.render_frame(window)
    GLWindow.swapbuffers(window)
    GLWindow.poll_glfw()
    GLWindow.poll_reactive()
    idx += 1
end

GLWindow.destroy!(window)
=======

center!(window, :orthographic_pixel) # center orthographic_pixel camera to what we just visualized

if !isdefined(:runtests)
    renderloop(window)
end
>>>>>>> master
