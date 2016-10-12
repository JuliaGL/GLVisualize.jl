using Plots, PlotRecipes, RData, GLVisualize, GeometryTypes;
pl_size = if !isempty(GLVisualize.get_screens())
    widths(GLVisualize.current_screen())
else
    (500,500)
end
glvisualize(size=pl_size)
tests = [1:5;7:20; 22; 24:30]
plots = [test_examples(:glvisualize, x) for x in tests]
plot(plots...)
