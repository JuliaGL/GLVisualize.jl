function postprocess(screen_texture, screen)
	data = merge(Dict(
		:resolution => lift(Vec2f0, screen.inputs[:framebuffer_size]),
		:u_texture0 => screen_texture
	), collect_for_gl(GLUVMesh2D(Rectangle(-1f0,-1f0, 2f0, 2f0))))
	program = TemplateProgram(
		File(shaderdir, "fxaa.vert"),
		File(shaderdir, "fxaa.frag"),
		File(shaderdir, "fxaa_combine.frag")
	)
	std_renderobject(data, program)
end

