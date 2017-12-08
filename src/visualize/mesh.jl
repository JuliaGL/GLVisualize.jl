function _default(mesh::TOrSignal{M}, s::Style, data::Dict) where M <: GLNormalAttributeMesh
    @gen_defaults! data begin
        main = mesh
        boundingbox = const_lift(GLBoundingBox, mesh)
        shading = true
        color = nothing
        shader = GLVisualizeShader(
            "fragment_output.frag", "util.vert", "attribute_mesh.vert", "standard.frag",
            view = Dict("light_calc" => light_calc(shading))
        )
    end
end

function _default(mesh::TOrSignal{M}, s::Style, data::Dict) where M <: GLNormalMesh
    @gen_defaults! data begin
        shading = true
        main = mesh
        color = default(RGBA{Float32}, s)
        boundingbox = const_lift(GLBoundingBox, mesh)

        shader = GLVisualizeShader(
            "fragment_output.frag", "util.vert", "standard.vert", "standard.frag",
            view = Dict("light_calc" => light_calc(shading))
        )
    end
end
function _default(mesh::TOrSignal{M}, s::Style, data::Dict) where M <: GLNormalUVMesh
    @gen_defaults! data begin
        shading = true
        main = mesh
        color = default(RGBA{Float32}, s) => Texture
        boundingbox = const_lift(GLBoundingBox, mesh)

        shader = GLVisualizeShader(
            "fragment_output.frag", "util.vert", "uv_normal.vert", "standard.frag",
            view = Dict("light_calc" => light_calc(shading))
        )
    end
end
function _default(mesh::TOrSignal{M}, s::Style, data::Dict) where M <: GLNormalVertexcolorMesh
    @gen_defaults! data begin
        shading = true
        main = mesh
        boundingbox = const_lift(GLBoundingBox, mesh)
        color = nothing
        shader = GLVisualizeShader(
            "fragment_output.frag", "util.vert", "vertexcolor.vert", "standard.frag",
            view = Dict("light_calc" => light_calc(shading))
        )
    end
end

function _default(mesh::GLNormalColorMesh, s::Style, data::Dict)
    data[:color] = decompose(RGBA{Float32}, mesh)
    _default(GLNormalMesh(mesh), s, data)
end

function _default(main::TOrSignal{M}, ::style"grid", data::Dict) where M <: GLPlainMesh
    @gen_defaults! data begin
        primitive::GLPlainMesh = main
        color = default(RGBA, s, 1)
        bg_colorc = default(RGBA, s, 2)
        grid_thickness = Vec3f0(2)
        gridsteps = Vec3f0(5)
        boundingbox = const_lift(GLBoundingBox, mesh)
        shader = GLVisualizeShader("fragment_output.frag", "grid.vert", "grid.frag")
    end
end


const VertexcolorMesh{VT, FT, NT, CT} = HMesh{Point{3, VT}, FT, Void, Void, Vector{CT}, Void, Void}
const GLVertexcolorMesh = NormalVertexcolorMesh{Float32, GLTriangle, Float32, RGBA{Float32}}

function _default(mesh::TOrSignal{M}, s::Style, data::Dict) where M <: Union{GLVertexcolorMesh, GLPlainMesh}
    @gen_defaults! data begin
        primitive = mesh
        color = hascolors(primitive) ? nothing : default(RGBA, s, 1)
        vertex_color = nothing
        boundingbox = const_lift(GLBoundingBox, mesh)
        shader = GLVisualizeShader("fragment_output.frag", "plain.vert", "plain.frag")
    end
end
