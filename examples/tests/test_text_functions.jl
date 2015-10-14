using AbstractGPUArray, GLAbstraction, GLWindow, GeometryTypes
using Base.Test
include(Pkg.dir("GLVisualize", "src", "visualize", "text", "utils.jl"))
w = createwindow("test", 10,10, debugging=true) # dummy window for opengl context


test_data = GPUVector(texture_buffer(map(Cint, collect("\nhallo_dolly jau whatup\ngragragagagag\n ima gangstaaa"))))
@test next_newline(test_data, 1) == 1
@test next_newline(test_data, 2) == 24
@test test_data[24] == '\n'

@test next_newline(test_data, 25) == 38
@test test_data[38] == '\n'

@test next_newline(test_data, 39) == 52
@test length(test_data) == 52


@test previous_newline(test_data, 1) == 1
@test previous_newline(test_data, 2) == 1
@test previous_newline(test_data, 27) == 24

@test previous_newline(test_data, 40) == 38

@test previous_newline(test_data, 52) == 38

test_text_selection = TextWithSelection(test_data, 1:3)

l = length(test_text_selection.text)
inserttext(test_text_selection, Cint[77,77,77,77,77])

@test l+2 == length(test_text_selection.text)
@test test_text_selection.text[1:5] == Cint[77,77,77,77,77]
@test test_text_selection.selection == 6:4

l = length(test_text_selection.text)
inserttext(test_text_selection, Cint[99,99,99,99,99])

@test test_text_selection.selection == 11:10
@test l+5 == length(test_text_selection.text)

l = length(test_text_selection.text)
test_text_selection.selection = 3:20
inserttext(test_text_selection, Cint[42])
@test l-length(3:20)+1 == length(test_text_selection.text)
@test test_text_selection.selection == 4:3


l = length(test_text_selection.text)
deletetext(test_text_selection)

@test test_text_selection.selection == 3:2
@test test_text_selection.text[3] != 42
@test l-1 == length(test_text_selection.text)