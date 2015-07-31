immutable SelectionID{T}
    objectid::T
    index::T
end
typealias GLSelection SelectionID{Uint16}
typealias ISelection SelectionID{Int}
function insert_selectionquery!(name::Symbol, value::Rectangle, selection, selectionquery)
    selectionquery[name] = value
    selection[name]         = Input(Vec{2, Int}[]')
    selection[name]
end
function insert_selectionquery!(name::Symbol, value::Signal{Rectangle{Int}}, selection, selectionquery)
    lift(value) do v
        selectionquery[name] = v
    end
    selection[name]         = Input(Array(Vec{2, Int}, value.value.w, value.value.h))
    selection[name]
end
function delete_selectionquery!(name::Symbol, selection, selectionquery)
    delete!(selectionquery, name)
    delete!(selection, name)
    nothing
end

function resizebuffers(window_size, color_buffer, objectid_buffer, depth_buffer)
    if all(x->x>0, window_size)
        resize_nocopy!(color_buffer,    tuple(window_size...))
        resize_nocopy!(objectid_buffer,  tuple(window_size...))
        glBindRenderbuffer(GL_RENDERBUFFER, depth_buffer[1])
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, window_size...)
    end
    nothing
end

function setup_framebuffers(framebuffsize::Signal{Vec{2, Int}})
    render_framebuffer = glGenFramebuffers()
    glBindFramebuffer(GL_FRAMEBUFFER, render_framebuffer)

    buffersize      = tuple(framebuffsize.value...)
    color_buffer    = Texture(RGBA{Ufixed8},     buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)
    objectid_buffer = Texture(Vec{2, GLushort}, buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, color_buffer.id, 0)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, objectid_buffer.id, 0)

    depth_buffer = GLuint[0]
    glGenRenderbuffers(1, depth_buffer)
    glBindRenderbuffer(GL_RENDERBUFFER, depth_buffer[1])
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, buffersize...)
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depth_buffer[1])

    lift(resizebuffers, framebuffsize, color_buffer, objectid_buffer, depth_buffer) 

    render_framebuffer, color_buffer, objectid_buffer, depth_buffer
end

function GLWindow.Screen(;name="GLVisualize", resolution=nothing, debugging=false)

    windowhints = [
        (GLFW.SAMPLES,      0), 
        (GLFW.DEPTH_BITS,   0), 
        
        (GLFW.ALPHA_BITS,   8),
        (GLFW.RED_BITS,     8),
        (GLFW.GREEN_BITS,   8),
        (GLFW.BLUE_BITS,    8),

        (GLFW.STENCIL_BITS, 0),
        (GLFW.AUX_BUFFERS,  0)
    ]
    GLFW.Init()
    if resolution == nothing 
        w, h = primarymonitorresolution()
        resolution = (div(w,2), div(h,2))
    end
    global const ROOT_SCREEN = createwindow(name, resolution..., windowhints=windowhints, debugging=debugging)
    screen = ROOT_SCREEN
    
    global const TIMER_SIGNAL = fpswhen(screen.inputs[:open], 60.0)

    render_framebuffer, color_buffer, objectid_buffer, depth_buffer = setup_framebuffers(screen.inputs[:framebuffer_size])
    postprocess_robj = postprocess(color_buffer, screen)

    selection      = Dict{Symbol, Input{Matrix{Vec{2, Int}}}}()
    selectionquery = Dict{Symbol, Rectangle{Int}}()
    insert_selectionquery!(:mouse_hover, lift(mouse_selection, screen.inputs[:mouseposition]), selection, selectionquery)
    add_complex_signals(screen, selection) #add the drag events and such
     
    FreeTypeAbstraction.init()
    fn = Pkg.dir("GLVisualize", "src", "texture_atlas", "DejaVuSansMono.ttf")
    @assert isfile(fn)
    global const DEFAULT_FONT_FACE = newface(fn)
    global const FONT_EXTENDS      = Dict{Int, FontExtent}()
    global const ID_TO_CHAR        = Dict{Int, Char}()

    map_fonts('\u0000':'\u00ff') # insert ascii chars, to make sure that the mapping for at least ascii characters is correct

   

    screen, () -> renderloop(screen, render_framebuffer, selectionquery, objectid_buffer, selection, postprocess_robj)
end


fps_max  = 0.0
fps_min  = typemax(Float64)
fps_mean = 0.0
frames_total = 0
function renderloop(screen, render_framebuffer, selectionquery, objectid_buffer, selection, postprocess_robj)
    while screen.inputs[:open].value
        renderloop_inner(screen, render_framebuffer, selectionquery, objectid_buffer, selection, postprocess_robj)
    end
    GLFW.Terminate()
    FreeTypeAbstraction.done()
    global fps_max, fps_min, fps_mean, frames_total
    println("fps_max: ", fps_max)
    println("fps_min: ", fps_min)
    println("fps_mean: ", fps_mean/frames_total)
end

function renderloop_inner(screen, render_framebuffer, selectionquery, objectid_buffer, selection, postprocess_robj)
    tic()
    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, render_framebuffer)
    glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    render(screen)

    #Read all the selection queries
    if !isempty(selectionquery)
        glReadBuffer(GL_COLOR_ATTACHMENT1)
        for (key, value) in selectionquery
            if value.w < 1 || value.w > 5000 || value.h < 1 || value.h > 5000
                println(value.w, " ", value.h) # debug output
            end
            const data = Array(Vec{2, Uint16}, value.w, value.h)
            glReadPixels(value.x, value.y, value.w, value.h, objectid_buffer.format, objectid_buffer.pixeltype, data)
            push!(selection[key], convert(Matrix{Vec{2, Int}}, data))
        end
    end
    yield()

    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glViewport(screen.area.value)
    glClear(GL_COLOR_BUFFER_BIT)
    render(postprocess_robj)
    GLFW.SwapBuffers(screen.nativewindow)
    GLFW.PollEvents()

    yield()
    t        = toq()
    target   = 1.0/60.0
    tosleep  = target - t

    global fps_max, fps_min, fps_mean, frames_total
    fps      = 1.0/t
    fps_max  = max(fps_max, fps)
    fps_min  = min(fps_max, fps)
    fps_mean += fps
    frames_total += 1
    tosleep > 0.0 && sleep(tosleep) # top up to reach 60 frames per second
end



mouse_selection(mpos) = Rectangle{Int}(round(Int, mpos[1]), round(Int, mpos[2]), 1, 1)


glClearColor(0.09411764705882353,0.24058823529411763,0.2401960784313726, 0)


# Transforms a mouse drag into a selection from drag start to drag end
function drag2selectionrange(v0, selection)
    mousediff, id_start, current_id = selection
    if mousediff != Vec2(0) # Mouse Moved
        if current_id[1] == id_start[1]
            return min(id_start[2],current_id[2]):max(id_start[2],current_id[2])
        end
    else # if mouse did not move while dragging, make a single point selection
        if current_id[1] == id_start[1]
            return current_id[2]:0 # this is the type stable way of indicating, that the selection is between currend_index
        end
    end
    v0
end

#Calculates mouse drag and supplies ID
function to_mousedragg_id(t0, mouse_down1, mouseposition1, objectid)
    mouse_down0, draggstart, objectidstart, mouseposition0, objectid0 = t0
    if !mouse_down0 && mouse_down1
        return (mouse_down1, mouseposition1, objectid, mouseposition1, objectid)
    elseif mouse_down0 && mouse_down1
        return (mouse_down1, draggstart, objectidstart, mouseposition1, objectid)
    end
    (false, Vec2(0), Vector2(0), Vec2(0), Vector2(0))
end
function diff_mouse(mouse_down_draggstart_mouseposition)
    mouse_down, draggstart, objectid_start, mouseposition, objectid_end = mouse_down_draggstart_mouseposition
    (draggstart - mouseposition, objectid_start, objectid_end)
end
function mousedragdiff_objectid(inputs, mouse_hover)
    @materialize mousebuttonspressed, mousereleased, mouseposition = inputs
    mousedown      = lift(isnotempty, mousebuttonspressed)
    mousedraggdiff = lift(diff_mouse, 
                        foldl(to_mousedragg_id, (false, Vec2(0), Vector2(0), Vec2(0), Vector2(0)), 
                            mousedown, mouseposition, mouse_hover
                        )
                    )
    return keepwhen(mousedown, (Vec2(0), Vector2(0), Vector2(0)), mousedraggdiff)
end

function to_arrow_symbol(button_set)
    GLFW.KEY_RIGHT in button_set && return :right
    GLFW.KEY_LEFT  in button_set && return :left
    GLFW.KEY_DOWN  in button_set && return :down
    GLFW.KEY_UP    in button_set && return :up
    return :nothing
end

function add_complex_signals(screen, selection)
    const mouse_hover   = lift(first, selection[:mouse_hover])

    mousedragdiff_id    = mousedragdiff_objectid(screen.inputs, mouse_hover)
    selection           = foldl(drag2selectionrange, 0:0, mousedragdiff_id)
    arrow_navigation    = lift(to_arrow_symbol, screen.inputs[:buttonspressed])

    screen.inputs[:mouse_hover]             = mouse_hover
    screen.inputs[:mousedragdiff_objectid]  = mousedragdiff_id
    screen.inputs[:selection]               = selection
    screen.inputs[:arrow_navigation]        = arrow_navigation
end



function fold_loop(v0, timediff_range)
    _, range = timediff_range
    v0 == last(range) && return first(range) 
    v0+step(range)
end

loop(range::Range; t=TIMER_SIGNAL) =
    foldl(fold_loop, first(range), lift(tuple, t, range))


function fold_bounce(v0, v1)
    _, range = v1
    val, direction = v0
    val += step(range)*direction
    if val > last(range) || val < first(range) 
    direction = -direction
    val += step(range)*direction
    end
    (val, direction)
end

bounce{T}(range::Range{T}; t=TIMER_SIGNAL) = 
    lift(first, foldl(fold_bounce, (first(range), one(T)), lift(tuple, t, range)))
