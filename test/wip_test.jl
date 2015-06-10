using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, MeshIO, Meshes, FileIO
using GLFW, ModernGL

const screen 	= GLVisualize.ROOT_SCREEN

t = readall(open("wip_test.jl"))

text 		= visualize(t, styles=Texture([RGBAU8(1,1,1,1), RGBAU8(0,0,1,1)]))

attributes = merge(
	GLVisualize.visualize_default("", Style{:default}()), 
	Dict(
		:screen     => GLVisualize.ROOT_SCREEN, 
		:model      => Input(eye(Mat4)),
		:technique 	=> :square,
		:styles 	=> Texture([RGBAU8(0,0,0,1.0), RGBAU8(0.,0.,1.,0.5)])
))

background 	= visualize(
	text[:glyphs], 
	text[:positions], 
	text[:style_index], 
	Style{:default}(),
	attributes
)
selection 	= add_edit(screen.inputs, background, text, t)

view(background)
view(text)
view(cursor(text[:positions], GLVisualize.ROOT_SCREEN, selection))


renderloop()