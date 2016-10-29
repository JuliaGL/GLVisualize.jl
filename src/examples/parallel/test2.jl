using GLVisualize, GLWindow
# start GLVisualize worker process
const workerid = workers()[]
fetch(eval(Main, :(@spawnat workerid begin
    window = GLVisualize.glscreen()
    @async GLWindow.renderloop(window)
    nothing
end)))
