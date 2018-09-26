using GLVisualize, GeometryTypes, GLAbstraction, Colors, FileIO

window = GLVisualize.glscreen(); δ = 0.45
ambientcolordefault = Vec3f0(0.1)
materialdefault = Vec4f0(0.9, 0.7, 0.3, 0.9) # (ambient, diffuse, specular, specularcolorcoeff) ∈ [0, 1]
shininessdefault = Float32(5.)
lightd = Vec3f0[Vec3f0(1.0, 1.0, 1.0), Vec3f0(0.1, 0.1, 0.1),
                Vec3f0(0.9, 0.9, 0.9), Vec3f0(20, 0, 20)]
markerm = :o
for x = 0:2
    for y = 0:2
        dc = linspace(0, 1, 3)[x + 1] * materialdefault[2]
        sc = linspace(0, 1, 3)[3 - y] * materialdefault[3]
        lmesh = if markerm == :o
            GLNormalMesh(Sphere{Float32}(Point3f0(x, y, 0), Float32(δ)), 50)
        elseif markerm == :□
            GLNormalMesh(GeometryTypes.HyperRectangle(Vec3f0(x - δ, y - δ , - δ),
                                                      Vec3f0(3 * δ / 2, 3 * δ / 2 , 3 * δ / 2)))
        end
        material = Vec4f0(1, dc, sc, 1.)
        GLVisualize._view(GLVisualize.visualize(lmesh, color = RGBA{Float32}(1, 0, 0, 1.),
                                                light = lightd, shininess = shininessdefault,
                                                material = material,
                                                ambientcolor = Vec3f0(0.01)), window)
    end
end
lighting = GLVisualize.Lighting([lightd[end],])
for x = 0:2
    for y = 0:2
        ac = if x == 0
            [0, 1, 0]
        elseif x == 1
            [0.5, 0, 1]
        elseif x == 2
            ones(3)
        end
        as = linspace(0, 1, 3)[y + 1] * materialdefault[1]
        lmesh = if markerm == :o
            GLNormalMesh(Sphere{Float32}(Point3f0(x , 2 - y - 4, 0), Float32(δ)), 50)
        elseif markerm == :□
            GLNormalMesh(GeometryTypes.HyperRectangle(Vec3f0(x - δ, 2 - y - δ - 4 , - δ),
                                                      Vec3f0(3 * δ / 2, 3 * δ / 2 , 3 * δ / 2)))
        end
        material = Vec4f0(as, materialdefault[2:end]...)
        GLVisualize._view(GLVisualize.visualize(lmesh, color = RGBA{Float32}(1, 0, 0, 1.),
                                                ambientcolor = Vec3f0(ac...),
                                                lighting = lighting, shininess = shininessdefault,
                                                material = material), window)
    end
end
GLVisualize.renderloop(window)
