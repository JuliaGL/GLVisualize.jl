using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

window = GLVisualize.glscreen(); δ = 0.45
lightd = Vec3f0[Vec3f0(1.0, 1.0, 1.0), Vec3f0(0.1, 0.1, 0.1),
                Vec3f0(0.9, 0.9, 0.9), Vec3f0(10, 50, 200)]
markerm = :o
#markerm = :□
for x = 0:2
    for y = 0:2
        dc = linspace(0, 1., 3)[x + 1]
        sc = linspace(0, .6, 3)[2 - y + 1]
        lmesh = if markerm == :o
            GLNormalMesh(Sphere{Float32}(Point3f0(x, y, 0), Float32(δ)), 50)
        elseif markerm == :□
            GLNormalMesh(GeometryTypes.HyperRectangle(Vec3f0(x - δ, y - δ , - δ),
                                                      Vec3f0(3 * δ / 2, 3 * δ / 2 , 3 * δ / 2)))
        end
        material = Vec4f0(1, dc, sc, 1.)
        GLVisualize._view(GLVisualize.visualize(lmesh, color = RGBA{Float32}(1, 0, 0, 1.),
                                                light = lightd, shininess = Float32(8.),
                                                material = material,
                                                ambientcolor = Vec3f0(0.01)), window)
    end
end
lighting = GLVisualize.Lighting([lightd[end],])
cd = 1.
for x = 0:2
    for y = 0:2
        ac = if x == 0
            [0, 1, 0]
        elseif x == 1
            [0.5, 0, 1]
        elseif x == 2
            ones(3)
        end
        ac /= cd
        as = linspace(0, 0.5, 3)[y + 1]
        lmesh = if markerm == :o
            GLNormalMesh(Sphere{Float32}(Point3f0(x , 2 - y - 4, 0), Float32(δ)), 50)
        elseif markerm == :□
            GLNormalMesh(GeometryTypes.HyperRectangle(Vec3f0(x - δ, 2 - y - δ - 4 , - δ),
                                                      Vec3f0(3 * δ / 2, 3 * δ / 2 , 3 * δ / 2)))
        end
        material = Vec4f0(as, 0.4, 0.8, 1.)
        GLVisualize._view(GLVisualize.visualize(lmesh, color = RGBA{Float32}(1, 0, 0, 1.),
                                                ambientcolor = Vec3f0(ac...),
                                                lighting = lighting, shininess = Float32(8.),
                                                material = material), window)
    end
end
GLVisualize.renderloop(window)
