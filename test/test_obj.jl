using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes
using Meshes, MeshIO, FileIO, WavefrontObj



import Base.(*)

immutable MeshMulFunctor{T} <: Base.Func{2}
	matrix::Matrix4x4{T}
end
Base.call{T}(m::MeshMulFunctor{T}, vert) = Vector3{T}(m.matrix*Vector4{T}(vert..., 1))
function *{T}(m::Matrix4x4{T}, mesh::Mesh)
	msh = deepcopy(mesh)
	println("vorher: ", length(msh.vertices), " ", length(msh.normals), " ", eltype(msh.vertices))
	map!(MeshMulFunctor(m), msh.vertices)
	println("nacher: ", length(msh.vertices), " ", length(msh.normals), " ", eltype(msh.vertices))
	msh
end


msh1 	= read(file"Rider.obj")
msh3 	= read(file"Thoat.OBJ")
msh 	= merge(msh1, msh3)
meshes 	= GLNormalMesh[]
for i=1:2, j=1:3
	push!(meshes, translationmatrix(Vec3(i*10f0,j*10f0, 0f0))*msh)
end

msh 	= merge(meshes)

write(file"test.ply_binary", msh)


robj 	= visualize(msh)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()