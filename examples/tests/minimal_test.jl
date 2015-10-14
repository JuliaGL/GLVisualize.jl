using GLAbstraction, ModernGL, GLWindow, MeshIO, Meshes, GeometryTypes, ColorTypes, Reactive, GLFW, FixedPointNumbers, FileIO

println(versioninfo())
function checkerror()
	err = glGetError()
	(err != GL_NO_ERROR) && error("shit... $(GLENUM(err).name)")
end
GLFW.Init()
    windowhints = [
        (GLFW.SAMPLES,      0),
        (GLFW.DEPTH_BITS,   0),

        (GLFW.ALPHA_BITS,   8),
        (GLFW.RED_BITS,     8),
        (GLFW.GREEN_BITS,   8),
        (GLFW.BLUE_BITS,    8),

        (GLFW.STENCIL_BITS, 0),
        (GLFW.AUX_BUFFERS,  0)
    ]
const ROOT_SCREEN = createwindow("Romeo", 1024, 1024, windowhints=windowhints, debugging=false)

frag_shader = frag"""
{{GLSL_VERSION}}

in vec3 o_normal;
in vec3 o_lightdir;
in vec3 o_vertex;
in vec4 o_color;
flat in uvec2 o_id;

out vec4 fragment_color;
out uvec2 fragment_groupid;


vec3 blinnphong(vec3 N, vec3 V, vec3 L, vec3 color)
{
    float diff_coeff = max(dot(L,N), 0.0);

    // specular coefficient
    vec3 H = normalize(L+V);

    float spec_coeff = pow(max(dot(H,N), 0.0), 8.0);
    if (diff_coeff <= 0.0)
        spec_coeff = 0.0;

    // final lighting model
    return  vec3(
            vec3(0.1)  * vec3(0.3)  +
            vec3(0.9)  * color * diff_coeff +
            vec3(0.3) * spec_coeff);
}

void main(){
    vec3 L      	= normalize(o_lightdir);
    vec3 N 			= normalize(o_normal);
    vec3 light1 	= blinnphong(N, o_vertex, L, o_color.rgb);
    vec3 light2 	= blinnphong(N, o_vertex, -L, o_color.rgb);
    fragment_color 	= vec4(light1+light2*0.4, o_color.a);
    if(fragment_color.a > 0.0)
        fragment_groupid = o_id;
}
"""
vert_util = vert"""
{{GLSL_VERSION}}

ivec2 ind2sub(ivec2 dim, int linearindex)
{
    return ivec2(linearindex % dim.x, linearindex / dim.x);
}

vec2 linear_index(ivec2 dims, int index)
{
    ivec2 index2D    = ind2sub(dims, index);
    return vec2(index2D) / vec2(dims);
}

vec4 linear_texture(sampler2D tex, int index)
{
    return texture(tex, linear_index(textureSize(tex, 0), index));
}

out vec3 o_normal;
out vec3 o_lightdir;
out vec3 o_vertex;
out vec4 o_color;


void render(vec3 vertex, vec3 normal, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4])
{
    vec4 position_camspace  = viewmodel * vec4(vertex,  1);
    // normal in world space
    o_normal                = normal;
    // direction to light
    o_lightdir              = normalize(light[3] - vertex);
    // direction to camera
    o_vertex                = -position_camspace.xyz;
    //
    o_color                 = color;
    // screen space coordinates of the vertex
    gl_Position             = projection * position_camspace;
}

struct Rectangle
{
    vec2 origin;
    vec2 width;
};
vec2 stretch(vec2 val, vec2 from, vec2 to)
{
    return from + (val * (to - from));
}
vec3 position(Rectangle rectangle, ivec2 dims, int index)
{
    return vec3(stretch(linear_index(dims, index), rectangle.origin, rectangle.width), 0);
}

"""


vert_shader = vert"""
{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

struct Rectangle
{
    vec2 origin;
    vec2 width;
};

in vec3 vertices;
in vec3 normals;

uniform vec3 light[4];
uniform sampler1D color;
uniform vec2 norm;

uniform vec2 grid_min;
uniform vec2 grid_max;

uniform sampler2D y_scale;
uniform vec3 scale;

uniform mat4 view, model, projection;

void render(vec3 vertex, vec3 normal, vec4 color, mat4 viewmodel, mat4 projection, vec3 light[4]);
vec4 linear_texture(sampler2D tex, int index);
vec3 position(Rectangle rectangle, ivec2 dims, int index);

uniform uint objectid;
flat out uvec2 o_id;

void main()
{
	vec3 pos 		= position(Rectangle(grid_min, grid_max), textureSize(y_scale, 0), gl_InstanceID);
	float intensity = linear_texture(y_scale, gl_InstanceID).x;
	pos 				+= vertices*vec3(scale.xy, scale.z*intensity);
	vec4 instance_color = vec4(1,0,1,1);
	render(pos, normals, instance_color, view*model, projection, light);
	o_id = uvec2(objectid, gl_InstanceID);
}
"""
function collect_for_gl{T <: HomogenousMesh}(m::T)
    result = Dict{Symbol, Any}()
    attribs = attributes(m)
    @materialize! vertices, faces = attribs
    result[:vertices]   = GLBuffer(vertices)
    result[:faces]      = indexbuffer(faces)
    for (field, val) in attribs
        if field in [:texturecoordinates, :normals, :attribute_id]
            result[field] = GLBuffer(val)
        else
            result[field] = Texture(val)
        end
    end
    result
end


function visualize_default(grid::Union{Texture{Float32, 2}, Matrix{Float32}})
    grid_min    = Vec2f0(-1, -1)
    grid_max    = Vec2f0( 1,  1)
    grid_length = grid_max - grid_min
    scale = Vec3f0((1f0 ./[size(grid)...])..., 1f0).* Vec3f0(grid_length..., 1f0)
    return Dict(
        :primitive  => GLNormalMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1.0))),
        :color      => RGBA{U8}[RGBA{U8}(1,0,0,1), RGBA{U8}(1,1,0,1), RGBA{U8}(0,1,0,1), RGBA{U8}(0,1,1,1), RGBA{U8}(0,0,1,1)],
        :grid_min   => grid_min,
        :grid_max   => grid_max,
        :scale      => scale,
        :norm       => Vec2f0(0, 5),
        :model      	  => Input(eye(Mat4f0)),
    	:light      	  => Input(Vec3f0[Vec3f0(1.0,1.0,1.0), Vec3f0(0.1,0.1,0.1), Vec3f0(0.9,0.9,0.9), Vec3f0(20,20,20)]),
    	:preferred_camera => :perspective
    )
end

function visualize(grid::Texture{Float32, 2}, customizations=visualize_default(grid))
    @materialize! color, primitive = customizations
    @materialize grid_min, grid_max, norm = customizations
    data = merge(Dict(
        :y_scale        => grid,
        :color          => Texture(color),
    ), collect_for_gl(primitive), customizations)
    program = TemplateProgram(
    	vert_util,
       	vert_shader,
        frag_shader
    )
    checkerror()
    robj = instanced_renderobject(data, length(grid), Input(program), Input(AABB(Vec3f0(0), Vec3f0(1))))
    checkerror()
    robj
end

robj = visualize(Texture(rand(Float32, 81,81)))

merge!(robj.uniforms, collect(PerspectiveCamera(ROOT_SCREEN.inputs, Vec3f0(2), Vec3f0(0))))

push!(ROOT_SCREEN.renderlist, robj)

const SELECTION         = Dict{Symbol, Input{Matrix{Vec{2, Int}}}}()
const SELECTION_QUERIES = Dict{Symbol, Rectangle{Int}}()
immutable SelectionID{T}
    objectid::T
    index::T
end
typealias GLSelection SelectionID{UInt16}
typealias ISelection SelectionID{Int}
function insert_selectionquery!(name::Symbol, value::Rectangle)
    SELECTION_QUERIES[name] = value
    SELECTION[name]         = Input(Vec{2, Int}[]')
    SELECTION[name]
end
function insert_selectionquery!(name::Symbol, value::Signal{Rectangle{Int}})
    const_lift(value) do v
    SELECTION_QUERIES[name] = v
    end
    SELECTION[name]         = Input(Array(Vec{2, Int}, value.value.w, value.value.h))
    SELECTION[name]
end
function delete_selectionquery!(name::Symbol)
    delete!(SELECTION_QUERIES, name)
    delete!(SELECTION, name)
end


const TIMER_SIGNAL = fpswhen(ROOT_SCREEN.inputs[:open], 30.0)

function fold_loop(v0, timediff_range)
    _, range = timediff_range
    v0 == last(range) && return first(range)
    v0+step(range)
end

loop(range::Range; t=TIMER_SIGNAL) =
    foldp(fold_loop, first(range), const_lift(tuple, t, range))


function fold_bounce(v0, v1)
    _, range = v1
    val, direction = v0
    val += step(range)*direction
    if val > last(range) || val < first(range)
    direction = -direction
    val += step(range)*direction
    end
    (val, direction)
end

bounce{T}(range::Range{T}; t=TIMER_SIGNAL) =
    const_lift(first, foldp(fold_bounce, (first(range), one(T)), const_lift(tuple, t, range)))

insert_selectionquery!(:mouse_hover, const_lift(ROOT_SCREEN.inputs[:mouseposition]) do mpos
    Rectangle{Int}(round(Int, mpos[1]), round(Int, mpos[2]), 1,1)
end)




global const RENDER_FRAMEBUFFER = glGenFramebuffers()
glBindFramebuffer(GL_FRAMEBUFFER, RENDER_FRAMEBUFFER)


framebuffsize = ROOT_SCREEN.inputs[:framebuffer_size].value
buffersize      = tuple(framebuffsize...)
COLOR_BUFFER    = Texture(RGBA{Ufixed8},     buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)
STENCIL_BUFFER = Texture(Vec{2, GLushort}, buffersize, minfilter=:nearest, x_repeat=:clamp_to_edge)
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, COLOR_BUFFER.id, 0)
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, STENCIL_BUFFER.id, 0)

const rboDepthStencil = GLuint[0]

glGenRenderbuffers(1, rboDepthStencil)
glBindRenderbuffer(GL_RENDERBUFFER, rboDepthStencil[1])
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, framebuffsize...)
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepthStencil[1])

const_lift(ROOT_SCREEN.inputs[:framebuffer_size]) do window_size
    if all(x->x>0, window_size)
        resize_nocopy!(COLOR_BUFFER, tuple(window_size...))
        resize_nocopy!(STENCIL_BUFFER, tuple(window_size...))
        glBindRenderbuffer(GL_RENDERBUFFER, rboDepthStencil[1])
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, (window_size)...)
    end
end
function postprocess(screen_texture, screen)
    data = merge(Dict(
        :resolution => const_lift(Vec2f0, screen.inputs[:framebuffer_size]),
        :u_texture0 => screen_texture
    ), collect_for_gl(GLUVMesh2D(Rectangle(-1f0,-1f0, 2f0, 2f0))))
    program = TemplateProgram(
        load(Pkg.dir("GLVisualize", "src", "shader", "fxaa.vert")),
        load(Pkg.dir("GLVisualize", "src", "shader", "fxaa.frag")),
        load(Pkg.dir("GLVisualize", "src", "shader", "fxaa_combine.frag"))
    )
    std_renderobject(data, program)
end



postprocess_robj = postprocess(COLOR_BUFFER, ROOT_SCREEN)

function renderloop()
    global ROOT_SCREEN
    while ROOT_SCREEN.inputs[:open].value
        renderloop(ROOT_SCREEN)
    end
    GLFW.Terminate()
end


function renderloop(screen)
    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, RENDER_FRAMEBUFFER)
    glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    render(screen)
    #Read all the selection queries
    if !isempty(SELECTION_QUERIES)
        glReadBuffer(GL_COLOR_ATTACHMENT1)
        for (key, value) in SELECTION_QUERIES
            if value.w < 1 || value.w > 5000
            println(value.w) # debug output
            end
            if value.h < 1 || value.h > 5000
            println(value.h) # debug output
            end
            const data = Array(Vec{2, UInt16}, value.w, value.h)
            glReadPixels(value.x, value.y, value.w, value.h, STENCIL_BUFFER.format, STENCIL_BUFFER.pixeltype, data)
            push!(SELECTION[key], convert(Matrix{Vec{2, Int}}, data))
        end
    end
    glDisable(GL_SCISSOR_TEST)
    glFlush()
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glViewport(screen.area.value)
    glClear(GL_COLOR_BUFFER_BIT)
    render(postprocess_robj)
    GLFW.SwapBuffers(screen.nativewindow)
    GLFW.PollEvents()
    yield()
    #sleep(0.001)
end

glClearColor(0.09411764705882353,0.24058823529411763,0.2401960784313726, 0)

renderloop()
