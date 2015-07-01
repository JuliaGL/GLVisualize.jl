const SELECTION         = Dict{Symbol, Input{Matrix{Vector2{Int}}}}()
const SELECTION_QUERIES = Dict{Symbol, Rectangle{Int}}()
immutable SelectionID{T}
    objectid::T
    index::T
end
typealias GLSelection SelectionID{Uint16}
typealias ISelection SelectionID{Int}
function insert_selectionquery!(name::Symbol, value::Rectangle)
    SELECTION_QUERIES[name] = value
    SELECTION[name]         = Input(Vector2{Int}[]')
    SELECTION[name]
end
function insert_selectionquery!(name::Symbol, value::Signal{Rectangle{Int}})
    lift(value) do v
    SELECTION_QUERIES[name] = v
    end
    SELECTION[name]         = Input(Array(Vector2{Int}, value.value.w, value.value.h))
    SELECTION[name]
end
function delete_selectionquery!(name::Symbol)
    delete!(SELECTION_QUERIES, name)
    delete!(SELECTION, name)
end


windowhints = [
    (GLFW.SAMPLES,      0), 
    (GLFW.DEPTH_BITS,   0), 
    (GLFW.ALPHA_BITS,   0), 
    (GLFW.STENCIL_BITS, 0),
    (GLFW.AUX_BUFFERS,  0)
]

const ROOT_SCREEN = createwindow("Romeo", 1920, 1280, windowhints=windowhints, debugging=false)
const TIMER_SIGNAL = fpswhen(GLVisualize.ROOT_SCREEN.inputs[:open], 30.0)

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
    
insert_selectionquery!(:mouse_hover, lift(ROOT_SCREEN.inputs[:mouseposition]) do mpos
    Rectangle{Int}(round(Int, mpos[1]), round(Int, mpos[2]), 1,1)
end)


const FRAME_BUFFER_PARAMETERS = [
    (GL_TEXTURE_WRAP_S,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_T,  GL_CLAMP_TO_EDGE ),

    (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
    (GL_TEXTURE_MAG_FILTER, GL_NEAREST) 
]

global const RENDER_FRAMEBUFFER = glGenFramebuffers()
glBindFramebuffer(GL_FRAMEBUFFER, RENDER_FRAMEBUFFER)


framebuffsize = [ROOT_SCREEN.inputs[:framebuffer_size].value...]
const COLOR_BUFFER   = Texture(RGBA{Ufixed8},     framebuffsize, parameters=FRAME_BUFFER_PARAMETERS)
const STENCIL_BUFFER = Texture(Vector2{GLushort}, framebuffsize, parameters=FRAME_BUFFER_PARAMETERS)

glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, COLOR_BUFFER.id, 0)
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, STENCIL_BUFFER.id, 0)

const rboDepthStencil = GLuint[0]

glGenRenderbuffers(1, rboDepthStencil)
glBindRenderbuffer(GL_RENDERBUFFER, rboDepthStencil[1])
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, framebuffsize...)
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepthStencil[1])

lift(ROOT_SCREEN.inputs[:framebuffer_size]) do window_size
    if all(x->x>0, window_size)
        resize_nocopy!(COLOR_BUFFER, tuple(window_size...))
        resize_nocopy!(STENCIL_BUFFER, tuple(window_size...))
        glBindRenderbuffer(GL_RENDERBUFFER, rboDepthStencil[1])
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, (window_size)...)
    end 
end


postprocess_robj = postprocess(COLOR_BUFFER, ROOT_SCREEN)

function renderloop()
    global ROOT_SCREEN
    while ROOT_SCREEN.inputs[:open].value
        renderloop(ROOT_SCREEN)
    end
    GLFW.Terminate()
    FreeTypeAbstraction.done()
end


function renderloop(screen)
    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, RENDER_FRAMEBUFFER)
    glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    render(screen)
    #Read all the selection queries
    if !isempty(SELECTION_QUERIES)
        glReadBuffer(GL_COLOR_ATTACHMENT1)
        for (key, value) in SELECTION_QUERIES
            if value.w < 1 || value.w > 5000
            println(value.w) # debug output
            end
            if value.h < 1 || value.h > 5000
            println(value.h) # debug output
            end
            const data = Array(Vector2{Uint16}, value.w, value.h)
            glReadPixels(value.x, value.y, value.w, value.h, STENCIL_BUFFER.format, STENCIL_BUFFER.pixeltype, data)
            push!(SELECTION[key], convert(Matrix{Vector2{Int}}, data))
        end
    end
    glDisable(GL_SCISSOR_TEST)
    glFlush()
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glViewport(screen.area.value)
    glClear(GL_COLOR_BUFFER_BIT)
    render(postprocess_robj)
    GLFW.SwapBuffers(screen.nativewindow)
    GLFW.PollEvents()
    yield() 
    sleep(0.001)
end

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
    isempty(button_set)         && return :nothing
    button = first(button_set)
    button == GLFW.KEY_RIGHT    && return :right
    button == GLFW.KEY_LEFT     && return :left
    button == GLFW.KEY_DOWN     && return :down
    button == GLFW.KEY_UP       && return :up
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

add_complex_signals(ROOT_SCREEN, SELECTION) #add the drag events and such