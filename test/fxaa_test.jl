using GLVisualize, GLAbstraction, Meshes, GeometryTypes, Reactive

postprocess_robj = GLVisualize.postprocess(Vec3(0f0), GLVisualize.ROOT_SCREEN)
screen = GLVisualize.ROOT_SCREEN
while screen.inputs[:open].value
	render(postprocess_robj)
	GLFW.SwapBuffers(screen.nativewindow)
	GLFW.PollEvents()
	yield()
end
