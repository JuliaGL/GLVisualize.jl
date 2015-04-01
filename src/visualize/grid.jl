function creategrid(;xrange::(Real, Real)=(-1,1), yrange::(Real, Real)=(-1,1), zrange::(Real, Real)=(-1,1), camera=pcamera)
	xyplane = genquad(Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(0, 1, 0))
	zyplane = genquad(Vec3(0, 0, 0), Vec3(0, 0, 1.2), Vec3(0, 1, 0))
	zxplane = genquad(Vec3(0, 1, 0), Vec3(0, 0, 1.2), Vec3(1, 0, 0))
	
	v,uv,n,i = mergemesh(xyplane, zyplane, zxplane)

	grid = RenderObject(@compat(Dict(
			:vertexes 			  	=> GLBuffer(v),
			:indexes			   	=> indexbuffer(i),
			#:grid_color 		  => Float32[0.1,.1,.1, 1.0],
			:bg_color 			  	=> Input(Vec4(1, 1, 1, 0.01)),
			:grid_thickness  		=> Input(Vec3(2)),
			:gridsteps  		  	=> Input(Vec3(10)),
			:mvp 				    => camera.projectionview
		)), gridshader)
	prerender!(grid, glDisable, GL_DEPTH_TEST, glDisable, GL_CULL_FACE, enabletransparency)
	postrender!(grid, render, grid.vertexarray)
	return grid
end

initgrid() = global gridshader = TemplateProgram(joinpath(shaderdir,"grid.vert"), joinpath(shaderdir,"grid.frag"))
init_after_context_creation(initgrid)

export creategrid

