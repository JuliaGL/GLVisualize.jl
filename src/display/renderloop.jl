immutable SelectionID{T}
    objectid::T
    index::T
end
typealias GLSelection SelectionID{UInt16}
typealias ISelection SelectionID{Int}
function insert_selectionquery!(name::Symbol, value::Rectangle, selection, selectionquery)
    selectionquery[name] = value
    selection[name]      = Input(Vec{2, Int}[]')
    selection[name]
end

insert_selectionquery(value, selectionquery, name) = selectionquery[name] = value


function insert_selectionquery!(name::Symbol, value::Signal{Rectangle{Int}}, selection, selectionquery)
    const_lift(insert_selectionquery, value, selectionquery, name)
    selection[name]  = Input(Array(Vec{2, Int}, value.value.w, value.value.h))
    selection[name]
end
function delete_selectionquery!(name::Symbol, selection, selectionquery)
    delete!(selectionquery, name)
    delete!(selection, name)
    nothing
end
immutable GLFramebuffer
    render_framebuffer:: GLuint
    color::              Texture{RGBA{Ufixed8}, 2}
    objectid::           Texture{Vec{2, GLushort}, 2}
    depth::              GLuint
end

function resizebuffers(window_size, framebuffer::GLFramebuffer)
    if all(x->x>0, window_size)
        resize_nocopy!(framebuffer.color,    tuple(window_size...))
        resize_nocopy!(framebuffer.objectid,  tuple(window_size...))
        glBindRenderbuffer(GL_RENDERBUFFER, framebuffer.depth)
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, window_size...)
    end
    nothing
end

function postprocess(framebuffer::GLFramebuffer, screen::Screen)
    data = merge(Dict(
        :resolution => const_lift(Vec2f0, screen.inputs[:framebuffer_size]),
        :u_texture0 => framebuffer.color
    ), collect_for_gl(GLUVMesh2D(Rectangle(-1f0,-1f0, 2f0, 2f0))))
    assemble_std(
        nothing, data,
        "fxaa.vert", "fxaa.frag", "fxaa_combine.frag"
    )
end

function GLFramebuffer(framebuffsize::Signal{Vec{2, Int}})
    render_framebuffer = glGenFramebuffers()
    glBindFramebuffer(GL_FRAMEBUFFER, render_framebuffer)

    buffersize      = tuple(framebuffsize.value...)
    color_buffer    = Texture(RGBA{Ufixed8},    buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)
    objectid_buffer = Texture(Vec{2, GLushort}, buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, color_buffer.id, 0)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, objectid_buffer.id, 0)

    depth_buffer = GLuint[0]
    glGenRenderbuffers(1, depth_buffer)
    db = depth_buffer[]
    glBindRenderbuffer(GL_RENDERBUFFER, db)
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, buffersize...)
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, db)
    fb = GLFramebuffer(render_framebuffer, color_buffer, objectid_buffer, db)
    const_lift(resizebuffers, framebuffsize, fb)
    fb
end

export glscreen

function glscreen()
	name="GLVisualize" 
	resolution=nothing 
	debugging=false

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
    global ROOT_SCREEN = createwindow(name, resolution..., windowhints=windowhints, debugging=debugging)
    screen = ROOT_SCREEN
    global TIMER_SIGNAL = fpswhen(screen.inputs[:open], 60.0)



    framebuffer = GLFramebuffer(screen.inputs[:framebuffer_size])
    screen.inputs[:framebuffer] = framebuffer
    postprocess_robj = postprocess(framebuffer, screen)

    selection      = Dict{Symbol, Input{Matrix{Vec{2, Int}}}}()
    selectionquery = Dict{Symbol, Rectangle{Int}}()
    insert_selectionquery!(:mouse_hover, const_lift(mouse_selection, screen.inputs[:mouseposition]), selection, selectionquery)
    add_complex_signals(screen, selection) #add the drag events and such

    FreeTypeAbstraction_init()
    fn = Pkg.dir("GLVisualize", "src", "texture_atlas", "hack_regular.ttf")
    isfile(fn) || error("Could not locate font at $fn")
    global DEFAULT_FONT_FACE = newface(fn)
    global FONT_EXTENDS      = Dict{Int, FontExtent}()
    global ID_TO_CHAR        = Dict{Int, Char}()

    map_fonts('\u0000':'\u00ff') # insert ascii chars, to make sure that the mapping for at least ascii characters is correct
    renderloop_fun(renderloop_callback=()->nothing) = renderloop(screen, selectionquery, selection, postprocess_robj, renderloop_callback)
    screen, renderloop_fun
end



function renderloop(screen, render_framebuffer, selectionquery, objectid_buffer, selection, postprocess_robj, renderloop_callback)
    while screen.inputs[:open].value
    	@async Reactive.run(10000)
        renderloop_inner(screen, render_framebuffer, selectionquery, objectid_buffer, selection, postprocess_robj)
    	@async Reactive.run(10000)
        renderloop_callback()
    end
    GLFW.Terminate()
    FreeTypeAbstraction_done()
end


function update_selectionqueries(selectionquery, objectid_buffer, selection, area)
    if !isempty(selectionquery)
        glReadBuffer(GL_COLOR_ATTACHMENT1)
        for (key, value) in selectionquery
            if value.x > 0 && value.y > 0 && value.w <= area.w && value.h <= area.h
                data = Array(Vec{2, UInt16}, value.w, value.h)
                glReadPixels(value.x, value.y, value.w, value.h, objectid_buffer.format, objectid_buffer.pixeltype, data)
                push!(selection[key], convert(Matrix{Vec{2, Int}}, data))
            end
        end
    end
end
function renderloop_inner(screen, render_framebuffer, objectid_buffer, selectionquery, selection, postprocess_robj)
    #tic()
    

    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, render_framebuffer)
    glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    render(screen)
    yield()
    #Read all the selection queries
    update_selectionqueries(selectionquery, objectid_buffer, selection, screen.area.value)

    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glViewport(screen.area.value)
    glClear(GL_COLOR_BUFFER_BIT)
    render(postprocess_robj)
    GLFW.SwapBuffers(screen.nativewindow)
    GLFW.PollEvents()

    yield()
end



mouse_selection(mpos) = Rectangle{Int}(round(Int, mpos[1]), round(Int, mpos[2]), 1, 1)



# Transforms a mouse drag into a selection from drag start to drag end
function drag2selectionrange(v0, selection)
    mousediff, id_start, current_id = selection
    if mousediff != Vec2f0(0) # Mouse Moved
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
    (false, Vec2f0(0), Vec(0,0), Vec2f0(0), Vec(0,0))
end

function diff_mouse(mouse_down_draggstart_mouseposition)
    mouse_down, draggstart, objectid_start, mouseposition, objectid_end = mouse_down_draggstart_mouseposition
    (draggstart - mouseposition, objectid_start, objectid_end)
end
function mousedragdiff_objectid(inputs, mouse_hover)
    @materialize mousebuttonspressed, mousereleased, mouseposition = inputs
    mousedown      = const_lift(isnotempty, mousebuttonspressed)
    mousedraggdiff = const_lift(diff_mouse,
        foldp(to_mousedragg_id, (false, Vec2f0(0), Vec(0,0), Vec2f0(0), Vec(0,0)),
            mousedown, mouseposition, mouse_hover
        )
    )
    return keepwhen(mousedown, (Vec2f0(0), Vec(0,0), Vec(0,0)), mousedraggdiff)
end

function to_arrow_symbol(button_set)
    GLFW.KEY_RIGHT in button_set && return :right
    GLFW.KEY_LEFT  in button_set && return :left
    GLFW.KEY_DOWN  in button_set && return :down
    GLFW.KEY_UP    in button_set && return :up
    return :nothing
end

function add_complex_signals(screen, selection)
    const mouse_hover   = const_lift(first, selection[:mouse_hover])

    mousedragdiff_id    = mousedragdiff_objectid(screen.inputs, mouse_hover)
    selection           = foldp(drag2selectionrange, 0:0, mousedragdiff_id)
    arrow_navigation    = const_lift(to_arrow_symbol, screen.inputs[:buttonspressed])

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
    foldp(fold_loop, first(range), const_lift(tuple, t, range))


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
    const_lift(first, foldp(fold_bounce, (first(range), one(T)), const_lift(tuple, t, range)))

function doubleclick(mouseclick, threshold)
    ddclick = foldp((time(), mouseclick.value, false), mouseclick) do v0, mclicked
        t0, lastc, _ = v0
        t1 = time()
        if length(mclicked) == 1 && length(lastc) == 1 && lastc[1] == mclicked[1] && t1-t0 < threshold
            return (t1, mclicked, true)
        else
            return (t1, mclicked, false)
        end
    end
    dd = const_lift(last, ddclick)
    return dd
end


function screenshot(window, path="screenshot.png")
    img = gpu_data(window.inputs[:framebuffer].color)[window.area.value]
    #save(path, rotl90(img), true)
end
export screenshot
