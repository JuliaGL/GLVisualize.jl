using GLVisualize
include("utf8_example_text.jl")
text = visualize(utf8_example_text)

background, cursor_robj, text_sig = vizzedit(text[:glyphs], text, GLVisualize.ROOT_SCREEN.inputs)

view(background)
view(text)
view(cursor_robj)

renderloop()

#push!(TEST_DATA2D, utf8_example_text)


