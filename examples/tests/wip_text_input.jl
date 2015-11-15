using GLWindow, GLFW, GLAbstraction, Reactive

w = createwindow("test", 10, 10)
include(Pkg.dir("GLVisualize", "src", "visualize", "text", "utils.jl"))

unicode 	= w.inputs[:unicodeinput]
keys 		= w.inputs[:buttonspressed]

selection 	= Signal(4:3)
text_raw 	= TextWithSelection([1,2,3,4], selection.value)
text 		= Signal(text_raw)
const_lift(s->(text_raw.selection=s), selection) # is there really no other way?!

Base.IntSet(a...) = IntSet(a)

strg_v 		= const_lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_V))
strg_c 		= const_lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_C))
strg_x 		= const_lift(==, keys, IntSet(GLFW.KEY_LEFT_CONTROL, GLFW.KEY_X))
del    		= const_lift(==, keys, IntSet(GLFW.KEY_DELETE))

clipboard_copy  = const_lift(copyclipboard,  filterwhen(strg_c, true, strg_v), 	text)
delete_text 	= const_lift(deletetext,     filterwhen(del, 	true, del), 	text)

clipboard_paste = const_lift(clipboardpaste, filterwhen(strg_v, true, strg_v))

text_gate 		= const_lift(isnotempty, unicode) #const_lift(AND, const_lift(is_textinput_modifiers, keys), const_lift(isnotempty, unicode))
unicode_input 	= filterwhen(text_gate, Char['0'], unicode)
text_to_insert 	= merge(clipboard_paste, unicode_input)
text_to_insert 	= const_lift(x->map(GLSprite, map_fonts(x)), text_to_insert)

const_lift(inserttext, text, text_to_insert)

while w.inputs[:open].value
	GLFW.PollEvents()
	sleep(0.01)
end

println(text)