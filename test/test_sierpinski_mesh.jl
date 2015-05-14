using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO
importall Base

typealias Point3f Point3{Float32}

translate{T <: Pyramid}(a::T, offset::Point3) = T(a.middle+offset, a.length, a.width)
scale{T <: Pyramid}(a::T, scale::Point3) 	  = T(a.middle.*scale, a.length*scale.z, a.width*scale.x)

function sierpinski(n, positions=Point3{Float32}[])
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
const n 	= 9
positions 	= sierpinski(n)

len         = length(positions)
println(len)
estimate    = sqrt(len)
pstride     = 2048
if len % pstride != 0
    append!(positions, fill(Point3f(typemax(Float32)), pstride-(len%pstride))) # append if can't be reshaped with 1024
end
positions = reshape(positions, (pstride, div(length(positions), pstride)))

const robj = visualize(
	positions, 
	model 		= scalematrix(Vec3(0.5^n)), 
	primitive 	= GLNormalMesh(Pyramid(Point3f(0), 1f0,1f0))
)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()