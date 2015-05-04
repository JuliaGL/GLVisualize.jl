using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO
 
function create_example_mesh()
    # volume of interest
    x_min, x_max = -1, 15
    y_min, y_max = -1, 5
    z_min, z_max = -1, 5
    scale = 8
 
    b1(x,y,z) = box(   x,y,z, 0,0,0,3,3,3)
    s1(x,y,z) = sphere(x,y,z, 3,3,3,sqrt(3))
    f1(x,y,z) = min(b1(x,y,z), s1(x,y,z))  # UNION
    b2(x,y,z) = box(   x,y,z, 5,0,0,8,3,3)
    s2(x,y,z) = sphere(x,y,z, 8,3,3,sqrt(3))
    f2(x,y,z) = max(b2(x,y,z), -s2(x,y,z)) # NOT
    b3(x,y,z) = box(   x,y,z, 10,0,0,13,3,3)
    s3(x,y,z) = sphere(x,y,z, 13,3,3,sqrt(3))
    f3(x,y,z) = max(b3(x,y,z), s3(x,y,z))  # INTERSECTION
    f(x,y,z) = min(f1(x,y,z), f2(x,y,z), f3(x,y,z))
 
    vol = volume(f, x_min,y_min,z_min,x_max,y_max,z_max, scale)
    msh = GLNormalMesh(vol, 0.0f0)
    return msh
end

msh  = create_example_mesh()
robj = visualize(msh)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

dirlen 	= 1f0
baselen = 0.02f0
axis 	= [
	(Cube(Vec3(baselen), Vec3(dirlen, baselen, baselen)), RGBA(1f0,0f0,0f0,1f0)), 
	(Cube(Vec3(baselen), Vec3(baselen, dirlen, baselen)), RGBA(0f0,1f0,0f0,1f0)), 
	(Cube(Vec3(baselen), Vec3(baselen, baselen, dirlen)), RGBA(0f0,0f0,1f0,1f0))
]
axis = map(GLNormalMesh, axis)
axis = merge(axis)

robj1 	= visualize(axis)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj1)


renderloop()