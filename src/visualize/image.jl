function visualize{T, D}(style::Style, img::Texture{T, D, 2}, data::Dict{Symbol, Any})
  kernel = data[:kernel]
  w, h  = img.dims
  texparams = [
     (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
    (GL_TEXTURE_MAG_FILTER, GL_NEAREST),
    (GL_TEXTURE_WRAP_S,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_T,  GL_CLAMP_TO_EDGE)
  ]

  v, uv, indexes = genquad(0f0, 0f0, w, h)
  if typeof(kernel) <: Real
    filterkernel = float32(kernel)
  elseif eltype(kernel) <: Union(AbstractArray, Real)
    filterkernel = Texture(kernel, parameters=texparams)
  end

  data = @compat Dict(
    :vertex           => GLBuffer(v, 2),
    :index            => indexbuffer(indexes),
    :uv               => GLBuffer(uv, 2),
    :image            => img,
    :normrange        => data[:normrange],
    :filterkernel     => filterkernel,
    :projectionview   => data[:screen].orthographiccam.projectionview,
    :model            => data[:model]
  )

  fragdatalocation = [(0, "fragment_color"),(1, "fragment_groupid")]
  textureshader    = TemplateProgram(joinpath(shaderdir, "uv_vert.vert"), joinpath(shaderdir, "texture.frag"), attributes=data, fragdatalocation=fragdatalocation)

  obj = RenderObject(data, textureshader)

  prerender!(obj, glDisable, GL_DEPTH_TEST, enabletransparency, glDisable, GL_CULL_FACE)
  postrender!(obj, render, obj.vertexarray)
  obj
end
