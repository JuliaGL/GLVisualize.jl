using ModernGL
using FileIO, MeshIO, GLAbstraction, GLVisualize, Reactive, GLWindow
using GeometryTypes, ColorTypes, Colors
using FactCheck

has_opengl = false
window = 0
windows = 0
number_of_windows = 6

# Allow window creation to fail, since there is enough to test even without
# OpenGL being present. This is important for travis, since we don't have OpenGL
# there
window = glscreen()
has_opengl = true


function view_boundingboxes(w, camera)
    bbs = []
    for renderlist in w.renderlist
        for robj in renderlist
            bb = boundingbox(robj)
            push!(bbs, visualize(value(bb), :lines, model=robj[:model]))
        end
    end
    for elem in bbs
        view(elem, w, camera=camera)
    end
end

windows = ntuple(number_of_windows) do i
    a = map(window.area) do wa
        h = wa.h÷number_of_windows
        SimpleRectangle(wa.x, (i-1)h, wa.w, h)
    end
    Screen(window, area=a)
end

function scale_gen(v0, nv)
	l = length(v0)
	@inbounds for i=1:l
		v0[i] = Vec3f0(1,1,sin((nv*l)/i))/3f0
	end
	v0
end
function color_gen(v0, nv)
    l = length(v0)
    @inbounds for x=1:l
        v0[x] = RGBA{U8}(x/l, (sin(nv)+1)/2, (sin(x/l/3)+1)/2.,1.)
    end
    v0
end
prima = centered(HyperRectangle)
primb = GLNormalMesh(centered(Sphere), 8)
cat   = GLNormalMesh(loadasset("cat.obj"))
a = rand(Point2f0, 20)
b = rand(Point3f0, 20)
c = collect(linspace(0.1f0,1.0f0,10f0))
d = rand(Float32, 10,10)
e = rand(Vec3f0, 5,5,5)

lastpos = Vec3f0(0)
particles = [
    visualize(elem, scale=Vec3f0(0.03))
    for elem in (b, (prima, a), (primb, b), (primb, c), d)
]

ps 			 = primb.vertices
time         = bounce(Float32(pi):0.01f0:(pi*2.0f0))
scale_start  = Vec3f0[Vec3f0(1,1,rand()) for i=1:length(ps)]
scale_signal = foldp(scale_gen, scale_start, time)
scale 		 = scale_signal
color_signal = foldp(color_gen, zeros(RGBA{U8}, length(ps)), time)
color 		 = color_signal
rotation     = -primb.normals

push!(particles, visualize((cat, ps), scale=scale, color=color, rotation=rotation))
push!(particles, visualize(e, scale=Vec3f0(0.3)))

if has_opengl
    view(visualize(particles), windows[1])
    view_boundingboxes(windows[1], :perspective)
end

typealias NColor{N, T} Colorant{T, N}
fillcolor{T <: NColor{4}}(::Type{T}) = T(0,1,0,1)
fillcolor{T <: NColor{3}}(::Type{T}) = T(0,1,0)
Base.rand(m::MersenneTwister, ::Type{U8}) = U8(rand(m, UInt8))
Base.rand{T <: Colorant}(m::MersenneTwister, ::Type{T}) = T(ntuple(x->rand(m, eltype(T)), Val{length(T)})...)
xy_data(x,y,i) = Float32(sin(x/i)*sin(y/i))
generate_distfield(i) = Float32[xy_data(x,y,i)+0.5f0 for x=1:64, y=1:64]
const dfdata = const_lift(generate_distfield, bounce(1f0:1f0:10f0))
facts("Image Like") do
    arrays = map(C-> C[fillcolor(C) for x=1:42,y=1:27] ,(RGBA{U8}, RGBA{Float32}, RGB{U8}, BGRA{U8}, BGR{Float32}))
    loaded_imgs = map(x->loadasset("test_images", x), readdir(assetpath("test_images")))
    intensities = GLIntensity[(sin(x/7)*cos(y/20))/sqrt(x) for x=1:50,y=1:50]
    intensities_s = const_lift(i->GLIntensity[(sin(x/i)*cos(y/(i/2f0)))/sqrt(x) for x=1:50,y=1:50], bounce(10f0:0.1f0:30f0))
    parametric_func = frag"""
       float function(float x) {
       	 return 1.0*sin(1/tan(x));
       }
    """

    context("viewable creation") do
        x = Any[arrays..., loaded_imgs..., intensities, intensities_s, loadasset("kittens-look.gif"), parametric_func]
        images = convert(Vector{Context}, map(visualize, x))
        push!(images, visualize(dfdata, :distancefield))
        if has_opengl
            images = visualize(images, direction=1, gap=Vec3f0(5))
            context("viewing") do
                gl_obj = view(images, windows[2], camera = :orthographic_pixel)
                view_boundingboxes(windows[2], :orthographic_pixel)

            end
        end
    end
end

function interpolate(a,b,t)
    [ae+((be-ae)*t) for (ae, be) in zip(a,b)]
end

function bounce_particles(pos_velo, _)
    positions, velocity = pos_velo
    dt = 0.1f0
    @inbounds for i=1:length(positions)
        pos,velo = positions[i], velocity[i]
        positions[i] = Point2f0(pos[1], pos[2] + velo*dt)
        if pos[2] <= 0f0
            velocity[i] = abs(velo)
        else
            velocity[i] = velo - 9.8*dt
        end
    end
    positions, velocity
end
facts("sprite particles") do

    context("on a 2D plane") do
        prima = SimpleRectangle(0f0,-0.5f0,1f0,1f0)
        primb = HyperSphere(Point2f0(0), 30f0)
        primc = HyperSphere(Point2f0(0), 40f0)

        a = rand(Point2f0, 10).*200f0
        b = rand(10f0:0.01f0:200f0, 10)
        interpolated = foldp((b,b,b), bounce(1f0:0.01f0:10f0)) do v0_v1_ip, td
            v0,v1,ip = v0_v1_ip
            pol = td%1
            if isapprox(pol,0.0)
                v0 = v1
                v1 = map(x-> rand(linspace(-x, 200f0-x, 100)), v0)
            end
            v0,v1,interpolate(v0,v1,pol)
        end
        b_sig = map(last, interpolated)
        c     = rand(Vec2f0, 5,5)
        c_sig = map(i->Vec2f0[(sin(x/i), cos(y/(i/2f0))) for x=1:5, y=1:5], bounce(1f0:0.05f0:5f0))
        a_vis = visualize(a, scale=Vec2f0(30))
        gpu_pos = a_vis.children[][:position]


        position_velocity = foldp(bounce_particles,
            (a, zeros(Float32, 10)),
            bounce(1:10)
        )

        circle_pos = Point2f0[(Point2f0(sin(i), cos(i))*50f0)+25f0 for i=linspace(0, 2pi, 20)]
        rotation   = Vec2f0[normalize(Vec2f0(25)-Vec2f0(p)) for p in circle_pos]
        scales     = map(bounce(0f0:0.1f0:1000f0)) do t
            Vec2f0[Vec2f0(10, ((sin(i+t)+1)/2)*40) for i=linspace(0, 2pi, 20)]
        end
        context("viewable creation") do
            particles = Context[
                a_vis,
                visualize((primb, gpu_pos), stroke_width=4f0, stroke_color=rand(RGBA{Float32}, 10), color=rand(RGBA{Float32}, 10)),
                visualize((DISTANCEFIELD, gpu_pos), stroke_width=4f0, stroke_color=rand(RGBA{Float32}, 10), color=rand(RGBA{Float32}, 10), distancefield=dfdata),
                visualize((primc, map(first, position_velocity)), image=loadasset("doge.png"), stroke_width=3f0, stroke_color=RGBA{Float32}(0.91,0.91,0.91,1), boundingbox=AABB(Vec3f0(0), Vec3f0(300,300,0))),
                visualize(('↺', c), ranges=((0,200),(0,200))),
                visualize(c_sig, ranges=((0,200),(0,200))),
                visualize((prima,b_sig), ranges=((0,200),),intensity=b_sig, color_norm=Vec2f0(10,200), color_map=GLVisualize.default(Vector{RGBA})),
                visualize((CIRCLE, circle_pos), rotation=rotation, scale=scales)
            ]
            if has_opengl
                context("viewing") do
                    gl_obj = view(visualize(particles, direction=1), windows[3], camera=:orthographic_pixel)
                    view_boundingboxes(windows[3], :orthographic_pixel)
                end
            end
        end
    end
    context("in 3D space") do
        prima = HyperRectangle{2, Float32}(Vec2f0(-0.1),Vec2f0(0.1))
        primb = Circle(Point2f0(0), 0.1f0)
        a = rand(Point3f0, 20)
        b = rand(Float32, 50,50)
        c = rand(Vec3f0, 5,5)
        d = rand(Vec3f0, 5,5,5)
        context("viewable creation") do
            particles = [
                visualize((prima,a)),
                visualize(('❄', a), scale=Vec2f0(0.1), billboard=true),
                visualize(c, scale=Vec3f0(0.1)),
                visualize(('➤', d), scale=Vec2f0(0.1))
            ]

            if has_opengl
                context("viewing") do
                    gl_obj = view(visualize(particles), windows[4], camera=:perspective)
                    view_boundingboxes(windows[4], :perspective)
                end
            end
        end
    end
end
function mgrid(dim1, dim2)
    X = [i for i in dim1, j in dim2]
    Y = [j for i in dim1, j in dim2]
    return X,Y
end
function mesh_surface(N)
    dphi, dtheta = pi/Float32(N), pi/Float32(N)
    phi,theta = mgrid(0f0:dphi:(pi+dphi*1.5f0), 0f0:dtheta:(2f0*pi+dtheta*1.5f0));
    m0 = 4f0; m1 = 3f0; m2 = 2f0; m3 = 3f0; m4 = 6f0; m5 = 2f0; m6 = 6f0; m7 = 4f0;
    a = sin(m0*phi).^m1;
    b = cos(m2*phi).^m3;
    c = sin(m4*theta).^m5;
    d = cos(m6*theta).^m7;
    r = a + b + c + d;
    x = r.*sin(phi).*cos(theta);
    y = r.*cos(phi);
    z = r.*sin(phi).*sin(theta);
    x,y,z
end
function xy_data(x,y,i, N)
	x = ((x/N)-0.5f0)*i
	y = ((y/N)-0.5f0)*i
	r = sqrt(x*x + y*y)
	Float32(sin(r)/r)
end
generate_surf_data(i, N) = Float32[xy_data(Float32(x),Float32(y),Float32(i), N) for x=1:N, y=1:N]
facts("Surfaces") do
    context("viewable creation") do
        x = Any[mesh_surface(50), generate_surf_data(20f0, 128)]
        surfs = Context[visualize(elem, :surface) for elem in x]
        if has_opengl
            suf_vizz = visualize(surfs, direction=1)
            context("viewing") do
                gl_obj = view(suf_vizz, windows[5])
                view_boundingboxes(windows[5], :perspective)
            end
        end
    end
end
function lines3Ddata(N, nloops)
    # The scalar parameter for each line
    TL = linspace(-2f0 * pi, 2f0 * pi, N)
    # We create a list of positions and connections, each describing a line.
    # We will collapse them in one array before plotting.
    xyz    = Point3f0[]
    colors = RGBA{Float32}[]
    # The index of the current point in the total amount of points
    base_colors1 = distinguishable_colors(nloops, RGB{Float32}(1,0,0))
    base_colors2 = distinguishable_colors(nloops, RGB{Float32}(1,1,0))
    # Create each line one after the other in a loop
    for i=1:nloops
        append!(xyz, [Point3f0(sin(t), cos((2 + .02 * i) * t), cos((3 + .02 * i) * t)) for t in TL])
        unique_colors = base_colors1[i]
        hsv = HSV(unique_colors)
        color_palette = map(x->RGBA{Float32}(x, 1.0), sequential_palette(hsv.h, N, s=hsv.s))
        append!(colors, color_palette)
    end
    xyz, colors
end

facts("Lines") do
    context("viewable creation") do
        lines, colors = lines3Ddata(200, 10)
        line_vizz = visualize(lines, :lines, color=colors)
        if has_opengl
            #suf_vizz = visualize(line_vizz, direction=1)
            context("viewing") do
                gl_obj = view(line_vizz, windows[6], camera=:perspective)
                view_boundingboxes(windows[6], :perspective)
            end
        end
    end
end

if has_opengl
    renderloop(window)
end
