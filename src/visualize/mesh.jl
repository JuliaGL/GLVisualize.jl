function _default{M<:GLNormalAttributeMesh}(mesh::TOrSignal{M}, s::Style, data::Dict)
    @gen_defaults! data begin
        main        = mesh
        boundingbox = const_lift(GLBoundingBox, mesh)
        shader      = GLVisualizeShader("fragment_output.frag", "util.vert", "attribute_mesh.vert", "standard.frag")
    end
end

function _default{M<:GLNormalMesh}(mesh::TOrSignal{M}, s::Style, data::Dict)
    @gen_defaults! data begin
        main        = value(mesh)
        color       = default(RGBA{Float32}, s)
        boundingbox = const_lift(GLBoundingBox, mesh)
        shader      = GLVisualizeShader("fragment_output.frag", "util.vert", "standard.vert", "standard.frag")
    end
end
function _default{M<:GLNormalVertexcolorMesh}(mesh::TOrSignal{M}, s::Style, data::Dict)
    @gen_defaults! data begin
        main         = value(mesh)
        boundingbox = const_lift(GLBoundingBox, mesh)
        shader         = GLVisualizeShader("fragment_output.frag", "util.vert", "vertexcolor.vert", "standard.frag")
    end
end

function _default(mesh::GLNormalColorMesh, s::Style, data::Dict)
    data[:color] = decompose(RGBA{Float32}, mesh)
    _default(GLNormalMesh(mesh), s, data)
end

function _default{M<:GLPlainMesh}(main::TOrSignal{M}, ::style"grid", data::Dict)
    @gen_defaults! data begin
        primitive       = main
        color           = default(RGBA, s, 1)
        bg_colorc       = default(RGBA, s, 2)
        grid_thickness  = Vec3f0(2)
        gridsteps       = Vec3f0(5)
        boundingbox     = const_lift(GLBoundingBox, mesh)
        shader          = GLVisualizeShader("fragment_output.frag", "grid.vert", "grid.frag")
    end
end
