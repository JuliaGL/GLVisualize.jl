using ModernGL
using FileIO, MeshIO, GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes, Colors
using FactCheck

has_opengl = false
window = 0
windows = 0
try
    window, renderloop = glscreen()
    @async renderloop()
    has_opengl = true
    WN = 3
    windows = ntuple(WN) do i
        a = map(window.area) do wa
            h = wa.h÷WN
            SimpleRectangle(wa.x, (i-1)h, wa.w, h)
        end
        Screen(window, area=a)
    end
catch e
    warn(string(
        "you don't seem to have opengl. Tests will run without OpenGL.
        If you're not in a VM and have a decent graphic card (> intel HD 3000),
        update drivers and if it still doesn't work, report an issue on github:",
        "\n", e
    ))
end

facts("mesh particles") do
    prima = centered(Cube)
    primb = GLNormalMesh(centered(Sphere))
    a = rand(Point2f0, 20)
    b = rand(Point3f0, 20)
    c = rand(Float32, 10)
    d = rand(Float32, 10,10)
    e = rand(Vec3f0, 5,5,5)

    context("viewable creation") do
        particles = [visualize(elem, scale=Vec3f0(0.03)) for elem in (b, (prima, a), (primb, b), (primb, c), d, e)]
        p1,p2,p3 = extract_renderable(Context(particles...))
        #@fact typeof(particles[1][:primitive]) --> Cube{Float32}
        #@fact typeof(p1[:primitive]) --> Cube{Float32}
        #@fact typeof(p2[:primitive]) --> GLNormalMesh

        #@fact particles[1][:positions] --> a
        #@fact p1[:positions] --> b
        #@fact p2[:positions] --> a
        #@fact p3[:positions] --> b

        if has_opengl
            context("viewing") do
                gl_obj = view(visualize(particles), windows[1])
                #@fact gpu_data(gl_obj[1][:positions]) --> a
                #@fact typeof(gl_obj[1][:positions]) --> TextureBuffer
                #@fact typeof(gl_obj[1][:vertices]) --> GLBuffer
            end
        end
    end
end
facts("sprite particles") do
    prima = centered(HyperRectangle{2, Float32})
    primb = centered(HyperSphere{2, Float32})
    a = rand(Point2f0, 20)
    b = rand(Point3f0, 20)
    c = rand(Float32, 10)
    d = rand(Float32, 10,10)
    e = rand(Vec3f0, 5,5)
    f = rand(Vec3f0, 5,5,5)

    context("viewable creation") do
        particles = [visualize(elem, scale=Vec3f0(0.03)) for elem in (b, (prima, a), (primb, b), e)]
        p1,p2,p3 = extract_renderable(Context(particles...))
        #@fact typeof(particles[1][:primitive]) --> Cube{Float32}
        #@fact typeof(p1[:primitive]) --> Cube{Float32}
        #@fact typeof(p2[:primitive]) --> GLNormalMesh

        #@fact particles[1][:positions] --> a
        #@fact p1[:positions] --> b
        #@fact p2[:positions] --> a
        #@fact p3[:positions] --> b

        if has_opengl
            context("viewing") do
                gl_obj = view(visualize(particles), windows[3])
                #@fact gpu_data(gl_obj[1][:positions]) --> a
                #@fact typeof(gl_obj[1][:positions]) --> TextureBuffer
                #@fact typeof(gl_obj[1][:vertices]) --> GLBuffer
            end
        end
    end
end


typealias NColor{N, T} Colorant{T, N}
fillcolor{T <: NColor{4}}(::Type{T}) = T(0,1,0,1)
fillcolor{T <: NColor{3}}(::Type{T}) = T(0,1,0)
facts("Images") do
    arrays = map(C-> C[fillcolor(C) for x=1:42,y=1:27] ,(RGBA{U8}, RGBA{Float32}, RGB{U8}, BGRA{U8}, BGR{Float32}))
    loaded_imgs = map(x->loadasset("test_images", x), readdir(assetpath("test_images")))
    context("viewable creation") do
        x = Any[arrays..., loaded_imgs...]
        images = convert(Vector{Context}, map(visualize, x))
        if has_opengl
            images = visualize(images, direction=1, gap=Vec3f0(5))
            context("viewing") do
                gl_obj = view(images, windows[2], method = :orthographic_pixel)
            end
        end
    end
end

if has_opengl
    while isopen(window)
        sleep(0.01)
        yield()
    end
end
