using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, Meshes, MeshIO

# install a time varying signal
const timer = Signal(1)  

function mkCube(p::GeometryTypes.Point3{Float32}, hsz::Float32)
    cube    = GLNormalMesh( Cube( Vec3( p.x, p.y, p.z), Vec3(hsz)))
    GLNormalMesh( cube.vertices, cube.faces)
end

function mkCube(p::GeometryTypes.Point3{Float32}, hsz::Reactive.Signal)
    const_lift(x -> mkCube( p, Float32(x/10)), hsz)
end

robj1 = visualize([ mkCube(Point3(0.5f0,0.0f0,0.0f0),timer),
          mkCube(Point3(0.0f0,0.5f0,0.0f0),timer)])

map (x -> push!(GLVisualize.ROOT_SCREEN.renderlist, x),  robj1)


@async renderloop() 

while GLVisualize.ROOT_SCREEN.inputs[:open].value
    yield()
    push!(timer, mod1(timer.value+1, 20))
end