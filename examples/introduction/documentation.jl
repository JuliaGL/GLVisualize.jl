using GLVisualize

import GLVisualize: get_docs, all_docs

# prints the documenation of parameters for visualizing a float matrix
get_docs(rand(Float32, 32, 32))
# prints the documenation of parameters for visualizing a float matrix in surface style
get_docs(rand(Float32, 32, 32), :surface)

# prints all visualization methods available with some documenation if available
io = IOBuffer()
all_docs(io)
String(take!(io)) # TODO test it returns the correct string!
