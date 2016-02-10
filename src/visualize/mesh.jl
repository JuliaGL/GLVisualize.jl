function _default{M<:GLNormalAttributeMesh}(mesh::TOrSignal{M}, s::Style, data::Dict)
    @gen_defaults! data begin
        main 		= mesh
        boundingbox = const_lift(GLBoundingBox, mesh)
        shader 		= GLVisualizeShader("util.vert", "attribute_mesh.vert", "standard.frag")
    end
end

function _default{M<:GLNormalMesh}(mesh::TOrSignal{M}, s::Style, data::Dict)
    @gen_defaults! data begin
        main 		= mesh
        color 		= default(RGBA{Float32}, s)
        boundingbox = const_lift(GLBoundingBox, mesh)
        shader 		= GLVisualizeShader("util.vert", "standard.vert", "standard.frag")
    end
end

function _default{M<:GLPlainMesh}(main::TOrSignal{M}, ::style"grid", data::Dict)
    @gen_defaults! data begin
        primitive       = main
        color           = default(RGBA, s, 1)
        bg_colorc       = default(RGBA, s, 2)
        grid_thickness  = Vec3f0(2)
        gridsteps       = Vec3f0(5)
        boundingbox     = const_lift(GLBoundingBox, mesh)
        shader          = GLVisualizeShader("grid.vert", "grid.frag")
    end
end

