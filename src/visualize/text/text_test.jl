using Cairo, GeometryTypes, FixedSizeArrays, GLAbstraction, ModernGL, GLVisualize, ColorTypes, FixedPointNumbers, Compat, MeshIO, Meshes
using FileIO
include("cairo_text.jl")
include("rectangle_packing.jl")
include("texture_atlas.jl")


# This is the low-level text interface, which simply prepares the correct shader and cameras
function GLVisualize.visualize(glyphs::Texture{GLGlyph, 2}, positions::Texture{Point2{Float16},2}, atlas::TextureAtlas=TEXTURE_ATLAS)#, ::Style{:default}, customization::Dict{Symbol, Any})
    screen = GLVisualize.ROOT_SCREEN
    camera = screen.orthographiccam
    data = merge(@compat(Dict(
    	:positions 			 => positions,
    	:glyphs 			 => glyphs,
        :projectionviewmodel => camera.projectionview,
        :uvs            	 => atlas.attributes,
        :images         	 => atlas.images,
        :styles         	 => Texture([RGBAU8(0,0,0,1)]),
    )), collect_for_gl(GLMesh2D(Rectangle(0f0,0f0,1f0,1f0))))
    shader = TemplateProgram(File(GLVisualize.shaderdir, "util.vert"), File(GLVisualize.shaderdir, "text.vert"), File(GLVisualize.shaderdir, "text.frag"))

    instanced_renderobject(data, length(glyphs), shader)
end



letters 	= "abcdefghijklmnobqrstuvwxyz"
lettersuc 	= uppercase(letters)
numbers 	= join(0:9)
glyphs 		= join([letters, lettersuc, numbers])
glyphs  	= map_fonts(glyphs)

glyphs 		= Texture(reshape(map(x->GLGlyph(x, 0), glyphs), (62, 1)))
positions	= Texture(reshape(Point2{Float16}[Point2{Float16}(i*100,100) for i=1:length(glyphs)], (62, 1)))

robj3 	= visualize(glyphs, positions)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj3)
glClearColor(1,1,1,1)
renderloop()

