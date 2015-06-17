using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, MeshIO, Meshes, FileIO
using GLFW, ModernGL
const screen = GLVisualize.ROOT_SCREEN

t = readall(open("wip_test.jl"))

text = visualize(t, styles=Texture([RGBAU8(1,1,1,1), RGBAU8(0,0,1,1)]))

attributes = merge(
	GLVisualize.visualize_default("", Style{:default}()), 
	Dict(
		:screen     => GLVisualize.ROOT_SCREEN, 
		:model      => Input(eye(Mat4)),
		:technique 	=> :square,
		:styles 	=> Texture([RGBAU8(0,0,0,0), RGBAU8(0.7,.5,1.,0.5)])
))


text_raw 	= TextWithSelection(text[:glyphs], 0:0)
text_edit 	= Input(text_raw)

background 	= visualize(
	text[:glyphs], 
	text[:positions], 
	GPUVector(texture_buffer(fill(GLSpriteStyle(0,0), length(text[:positions])))), 
	Style{:default}(),
	attributes
)

selection = add_edit(screen.inputs, background, text, text_edit)
#lift(println, selection)

lift(s->(text_edit.value.selection=s), selection) # is there really no other way?!


w = GLVisualize.ROOT_SCREEN

unicode 	= w.inputs[:unicodeinput]
keys 		= w.inputs[:buttonspressed]



Base.IntSet(a...) 	= IntSet(a)

strg_v 		= lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_V))
strg_c 		= lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_C))
strg_x 		= lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_X))
del    		= lift(==, keys, IntSet(GLFW.KEY_BACKSPACE))

clipboard_copy  = lift(copyclipboard,  keepwhen(strg_c, true, strg_v), 	text_edit)

delete_text 	= lift(deletetext,     keepwhen(del, 	true, del), 	text_edit)
cut_text 		= lift(deletetext,     keepwhen(strg_x, true, strg_x), 	text_edit)


clipboard_paste = lift(clipboardpaste, keepwhen(strg_v, true, strg_v))

text_gate 		= lift(isnotempty, unicode)
unicode_input 	= keepwhen(text_gate, Char['0'], unicode)
text_to_insert 	= merge(clipboard_paste, unicode_input)
text_to_insert 	= lift(process_for_gl, text_to_insert)


return_nothing(x...) = nothing
text_inserted = lift(inserttext, text_edit, text_to_insert)
text_updates = merge(
	lift(return_nothing, text_inserted), 
	lift(return_nothing, clipboard_copy), 
	lift(return_nothing, delete_text), 
	lift(return_nothing, cut_text), 
	lift(return_nothing, selection)
)
text_selection_signal = sampleon(text_updates, text_edit)

selection 	= lift(x->x.selection, text_selection_signal)
text_sig 	= lift(x->x.text, text_selection_signal)
lift(text_sig) do glyphs
	oldpos = text[:positions]
	positions = GLVisualize.calc_position(glyphs)
	length(oldpos) != length(positions) && resize!(oldpos, length(positions))
	update!(oldpos.buffer, positions)
end
foldl(GLVisualize.visualize_selection, 0:0, selection, Input(background[:style_index]))

view(background, 							method=:orthographic_pixel)
view(text, 									method=:orthographic_pixel)
view(cursor(text[:positions], selection), 	method=:orthographic_pixel)


renderloop()

