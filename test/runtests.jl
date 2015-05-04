using GeometryTypes, MeshIO, Meshes, ColorTypes, GLAbstraction, GLVisualize, Reactive
using Base.Test

dirlen 	= 1f0
baselen = 0.02f0
axis 	= [
	(Cube(Vec3(baselen), Vec3(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)), 
	(Cube(Vec3(baselen), Vec3(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)), 
	(Cube(Vec3(baselen), Vec3(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
]
axis = map(GLNormalMesh, axis)
const axis_mesh = merge(axis)
const N1 = 7
funcy(x,y,z) = Vec3(sin(x),cos(y),tan(z))
const directions  = Vec3[funcy(x,y,z) for x=1:N1,y=1:N1, z=1:N1]

const N = 128
const counter = 15f0
volume 	= Float32[sin(x/counter)+sin(y/counter)+sin(z/counter) for x=1:N, y=1:N, z=1:N]
max 	= maximum(volume)
min 	= minimum(volume)
const volume_norm 	= (volume .- min) ./ (max .- min)
const grid = Array(Any, 2,2)

grid[1,1] = rand(Float32, 50,50)
grid[1,2] = axis_mesh
grid[2,1] = directions
grid[2,2] = volume_norm
msh= GLNormalMesh(AABB(Vec3(-1), Vec3(1)))

results = map(grid) do obj
	trans = Input(eye(Mat4)) # get a handle to the translation matrix
	(trans, visualize(obj, model=trans))
end

grid_position = Vec3(0,0,0)
direction = Vec3(1,0,0)
for (model, robj) in results
	bb = robj.boundingbox.value
	push!(model, translationmatrix(grid_position-bb.min))
	grid_position += ((bb.max-bb.min).*direction)
end

append!(GLVisualize.ROOT_SCREEN.renderlist, vec(map(last, results)))

renderloop()
