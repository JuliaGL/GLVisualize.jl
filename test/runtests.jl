using ModernGL
using FileIO, MeshIO, GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes, Colors
using FactCheck

has_opengl = false
window = 0
try
    window, renderloop = glscreen()
    @async renderloop()
    has_opengl = true
catch e
    warn(string(
        "you don't seem to have opengl. Tests will run without OpenGL.
        If you're not in a VM and have a decent graphic card (> intel HD 3000),
        update drivers and if it still doesn't work, report an issue on github:",
        "\n", e
    ))
end

facts("particles") do
    prima = centered(Cube)
    primb = GLNormalMesh(centered(Sphere))
    a = [rand(Point2f0) for i=1:20]
    b = [rand(Point3f0) for i=1:20]

    context("viewable creation") do
        particles = map(visualize, (b, (prima, a), (primb, b)))
        p1,p2,p3 = extract_renderable([particles...])
        println(typeof(p1))
        println(typeof(p2))
        println(typeof(p3))
        #@fact typeof(particles[1][:primitive]) --> Cube{Float32}
        @fact typeof(p1[][:primitive]) --> Cube{Float32}
        @fact typeof(p2[][:primitive]) --> GLNormalMesh

        #@fact particles[1][:positions] --> a
        @fact p1[][:positions] --> b
        @fact p2[][:positions] --> a
        @fact p3[][:positions] --> b

        if has_opengl
            context("viewing") do
                gl_obj = map(x->view(x), particles)
                @fact gpu_data(gl_obj[1][:positions]) --> a
                @fact typeof(gl_obj[1][:positions]) --> TextureBuffer
                @fact typeof(gl_obj[1][:vertices]) --> GLBuffer
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
