using GLVisualize

# prints the documenation of parameters for visualizing a float matrix
get_docs(rand(Float32, 32, 32))
# prints the documenation of parameters for visualizing a float matrix in surface style
get_docs(rand(Float32, 32, 32), :surface)

# prints all visualization methods available with some documenation if available
all_docs()
