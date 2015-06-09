using GLVisualize, ModernGL, GLWindow, GLAbstraction, GeometryTypes, Reactive

typealias Point3f Point3{Float32}
N = 40_000
const time_i 		= bounce(1f0:0.001f0:20f0) # lets the values "bounce" back and forth between 1 and 50, f0 for Float32
const start_pos 	= Point3{Float32}[rand(Point3{Float32}, 0f0:eps(Float32):1f0)*5f0 for i=1:N]
generate(i, start) 	= convert(Array{Point3{Float32},1}, start.*i)
const a 	= lift(generate, time_i, start_pos)

buff = GLBuffer(a.value, buffertype=GL_TEXTURE_BUFFER)
tex = Texture(buff)
robj = visualize(tex, scale=Vec3(0.003))
function update_lol(t,b,x)
    glBindBuffer(b.buffertype, b.id)
    glBufferSubData(b.buffertype, 0, sizeof(x), x)
    glTexBuffer(t.texturetype, t.internalformat, b.id)
end

lift(update_lol, tex, buff, a)

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()
