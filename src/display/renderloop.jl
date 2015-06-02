const SELECTION         = Dict{Symbol, Input{Matrix{Vector2{Int}}}}()
const SELECTION_QUERIES = Dict{Symbol, Rectangle{Int}}()

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
    yield() 
    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, RENDER_FRAMEBUFFER)
    glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    render(screen)
    yield() 
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
    yield() 
    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glClear(GL_COLOR_BUFFER_BIT)

    render(postprocess_robj)
    GLFW.SwapBuffers(screen.nativewindow)
    GLFW.PollEvents()
    yield() 

end

glClearColor(0, 0, 0, 0)

