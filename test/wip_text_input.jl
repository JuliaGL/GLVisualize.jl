using GLWindow, GLFW, GLAbstraction, Reactive

w = createwindow("test", 10, 10)
include(Pkg.dir("GLVisualize", "src", "visualize", "text", "utils.jl"))

unicode 	= w.inputs[:unicodeinput]
keys 		= w.inputs[:buttonspressed]

selection 	= Input(4:3)
text_raw 	= TextWithSelection([1,2,3,4], selection.value)
text 		= Input(text_raw)
lift(s->(text_raw.selection=s), selection) # is there really no other way?!

Base.IntSet(a...) = IntSet(a)

strg_v 		= lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_V))
strg_c 		= lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_C))
strg_x 		= lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_X))
del    		= lift(==, keys, IntSet(GLFW.KEY_DELETE))

clipboard_copy  = lift(copyclipboard,  keepwhen(strg_c, true, strg_v), 	text)
delete_text 	= lift(deletetext,     keepwhen(del, 	true, del), 	text)

clipboard_paste = lift(clipboardpaste, keepwhen(strg_v, true, strg_v))

text_gate 		= lift(isnotempty, unicode) #lift(AND, lift(is_textinput_modifiers, keys), lift(isnotempty, unicode))
unicode_input 	= keepwhen(text_gate, Char['0'], unicode)
text_to_insert 	= merge(clipboard_paste, unicode_input)
text_to_insert 	= lift(x->map(GLSprite, map_fonts(x)), text_to_insert)

lift(inserttext, text, text_to_insert)

while w.inputs[:open].value
	GLFW.PollEvents()
	sleep(0.01)
end

println(text)