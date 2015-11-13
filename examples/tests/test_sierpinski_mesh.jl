typealias Point3f Point3{Float32}

function sierpinski(n, positions=Point3f[])
    if n == 0
        push!(positions, Point3f(0))
        positions
    else
        t = sierpinski(n - 1, positions)
        for i=1:length(t)
        	t[i] = t[i] * 0.5f0
        end
        t_copy = copy(t)
        mv = (0.5^n * 2^n)/2f0
        mw = (0.5^n * 2^n)/4f0
        append!(t, [p + Point3f(mw, mw, -mv) 	for p in t_copy])
        append!(t, [p + Point3f(mw, -mw, -mv) 	for p in t_copy])
        append!(t, [p + Point3f(-mw, -mw, -mv) 	for p in t_copy])
        append!(t, [p + Point3f(-mw, mw, -mv) 	for p in t_copy])
        t
    end
end
function sierpinski_data(n)
    positions 	= sierpinski(n)
    return (positions, :scale => Vec3(0.5^n), :primitive => GLNormalMesh(Pyramid(Point3f(0), 1f0,1f0)))
    #return visualize(positions, scale=Vec3(0.5^n), primitive=GLNormalMesh(Pyramid(Point3f(0), 1f0,1f0)))
end
sierpinski_data(4)
push!(TEST_DATA, sierpinski_data(4))
#=
using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, MeshIO, Meshes, FileIO
using GLFW, ModernGL
view(sierpinski_data(4))
renderloop()
=#