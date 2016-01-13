function postprocess(color::Texture, framebuffer_size)
    extract_renderable(assemble_shader(@gen_defaults! Dict{Symbol, Any}() begin
        main       = nothing
        model      = eye(Mat4f0)
        resolution = const_lift(Vec2f0, framebuffer_size)
        u_texture0 = color
        primitive  = GLUVMesh2D(SimpleRectangle(-1f0,-1f0, 2f0, 2f0))
        shader     = GLVisualizeShader("fxaa.vert", "fxaa.frag", "fxaa_combine.frag")
    end))[]
end

export glscreen

const windowhints = [
    (GLFW.SAMPLES,      0),
    (GLFW.DEPTH_BITS,   0),
    
    (GLFW.ALPHA_BITS,   8),
    (GLFW.RED_BITS,     8),
    (GLFW.GREEN_BITS,   8),
    (GLFW.BLUE_BITS,    8),

    (GLFW.STENCIL_BITS, 0),
    (GLFW.AUX_BUFFERS,  0)
]

function glscreen(;
        name="GLVisualize", resolution=default_screen_resolution(), debugging=true
    )
    screen = createwindow(name, resolution..., windowhints=windowhints, debugging=debugging)
    global ROOT_SCREEN  = screen
    global TIMER_SIGNAL = fpswhen(screen.inputs[:open], 60.0)

    framebuffer = GLFramebuffer(screen.inputs[:framebuffer_size])
    screen.inputs[:framebuffer] = framebuffer

    add_complex_signals(screen, selection) #add the drag events and such

    glClearColor(1,1,1,1)
    renderloop_fun(renderloop_callback=()->nothing) = renderloop(screen, selectionquery, selection, renderloop_callback)
    screen, renderloop_fun
end
