#=
function arbitrary_surface_data(N)
	h = 1./N
	r = h:h:1.
	t = (-1:h:1+h)*π
	x = map(Float32, r*cos(t)')
	y = map(Float32, r*sin(t)')

	f(x,y)  = exp(-10x.^2-20y.^2)  # arbitrary function of f
	z       = Float32[Float32(f(x[k,j],y[k,j])) for k=1:size(x,1),j=1:size(x,2)]
	visualize(x, y, z, :surface)
end
push!(TEST_DATA, arbitrary_surface_data(100))
println("Barplot")
# Barplot
push!(TEST_DATA, visualize(Float32[(sin(i/10f0) + cos(j/2f0))/4f0 + 1f0 for i=1:50, j=1:50]))
println("3d dot particles")

# 3d dot particles
function dots_data(N)
	start_point = Point3f0(0f0)
	randrange = -0.1f0:eps(Float32):0.1f0
	return visualize(Point3f0[(start_point += rand(Point3f0, randrange)) for i=1:N], :dots)
end
push!(TEST_DATA, dots_data(25_000))

println("some more funcitonality from Meshes")


# obj import
push!(TEST_DATA, visualize(GLNormalMesh(loadasset("cat.obj"))))

println("particles")

# particles
generate_particles(N,x,i) = Point3f0(
	sin(i+x/20f0),
	cos(i+x/20f0),
	Float32((2x/N)+i/10f0)
)
update_particles(i, N) 		= Point3f0[generate_particles(N,x, i) for x=1:N]
particle_color(positions) 	= RGBA{U8}[RGBA{U8}(((cos(pos[1])+1)/2),0.0,((sin(pos[2])+1)/2),  1.0f0) for pos in positions]
function particle_data(N)
	locations 	= const_lift(update_particles, bounce(1f0:0.1f0:10f0), N)
	colors 		= const_lift(particle_color, locations)
	visualize(locations, color=colors, scale=Vec3f0(0.03))
end
push!(TEST_DATA, particle_data(1024))
particle_color_pulse(x) = RGBA(x, 0f0, 1f0-x, 1f0)
push!(TEST_DATA,  visualize(
	(GLNormalMesh(loadasset("cat.obj")), Point3f0[rand(Point3f0, 0f0:0.001f0:2f0) for i=1:1024]),
	color 		= const_lift(particle_color_pulse, bounce(0f0:0.1f0:1f0)),
	scale 		= Vec3f0(0.3)
))

println("sierpinski")

# sierpinski particles
function sierpinski(n, positions=Point3f0[])
    if n == 0
        push!(positions, Point3f0(0))
        positions
    else
        t = sierpinski(n - 1, positions)
        for i=1:length(t)
        	t[i] = t[i] * 0.5f0
        end
        t_copy = copy(t)
        mv = (0.5^n * 2^n)/2f0
        mw = (0.5^n * 2^n)/4f0
        append!(t, [p + Point3f0(mw, mw, -mv) 	for p in t_copy])
        append!(t, [p + Point3f0(mw, -mw, -mv) 	for p in t_copy])
        append!(t, [p + Point3f0(-mw, -mw, -mv) 	for p in t_copy])
        append!(t, [p + Point3f0(-mw, mw, -mv) 	for p in t_copy])
        t
    end
end
function sierpinski_data(n)
    positions = sierpinski(n)
    prim = GLNormalMesh(Pyramid(Point3f0(0), 1f0,1f0))
    return visualize((prim, positions), scale = Vec3f0(0.5^n))
end

push!(TEST_DATA, sierpinski_data(4))

println("surface")
# surface plot
function xy_data(x,y,i, N)
	x = ((x/N)-0.5f0)*i
	y = ((y/N)-0.5f0)*i
	r = sqrt(x*x + y*y)
	Float32(sin(r)/r)
end
generate(i, N) = Float32[xy_data(Float32(x),Float32(y),Float32(i), N) for x=1:N, y=1:N]

function surface_data(N)
	heightfield = const_lift(generate, bounce(1f0:200f0), N)
	return visualize(heightfield, :surface, color_norm=Vec2f0(-0.21, 1.0))
end
a = colormap("RdBu")
b = map(x->RGBA{U8}(x.r, x.g, x.b, 1.), a)
c = colormap("Blues")
d = map(x->RGBA{U8}(x.r, x.g, x.b, 1.), c)
push!(TEST_DATA, visualize(generate(20f0, 128), :surface, color=b))
push!(TEST_DATA, visualize(generate(25f0, 128), :surface, color=d))
push!(TEST_DATA, surface_data(128))

println("vectorfielddata")

# vectorfield
vectorfielddata(N, i) = Vec3f0[Vec3f0(Float32(cos(x/N*3f0)*i), cos(y/7i), cos(i/5f0)) for x=1:N, y=1:N, z=1:N]

const t = bounce(1f0:0.1f0:5f0)

push!(TEST_DATA, visualize(vectorfielddata(14, 1f0)))
push!(TEST_DATA, visualize(const_lift(vectorfielddata, 7, t), color_norm=Vec2f0(1, 5)))
println("volume_data")

# volume rendering
function volume_data(N)
	volume 	= Float32[sin(x/15.0)+sin(y/15.0)+sin(z/15.0) for x=1:N, y=1:N, z=1:N]
	max 	= maximum(volume)
	min 	= minimum(volume)
	volume 	= (volume .- min) ./ (max .- min)
end


const vol_data = volume_data(32)
push!(TEST_DATA, visualize(vol_data, :mip))
push!(TEST_DATA, visualize(vol_data, :absorption, absorption=bounce(0f0:1f0:50f0)))
push!(TEST_DATA, visualize(vol_data, :iso, isovalue=bounce(0f0:0.01f0:1f0)))


###########################################################################
###########################################################################
# 2D Test Data
##############################################grid2D#############################
###########################################################################



#2D distance field
xy_data(x,y,i) = Float32(sin(x/i)*sin(y/i))
generate_distfield(i) = Float32[xy_data(x,y,i) for x=1:512, y=1:512]
const dfdata = const_lift(generate_distfield, bounce(50f0:500f0))
push!(TEST_DATA2D, visualize(dfdata, :distancefield))
=#


function image_test_data(N)
	test_image_dir = assetpath("test_images")
	abs_paths = map(x->joinpath(test_image_dir, x), readdir(test_image_dir))
    ims = (
        RGBA{U8}[RGBA{U8}(abs(sin(i)), abs(sin(j)), abs(cos(i)), abs(sin(j)*cos(i))) for i=1:0.1:N, j=1:0.1:N],
        map(load, abs_paths)...
    )
	return map(visualize, ims)
end


push!(TEST_DATA2D, image_test_data(20)...)
let gif = loadasset("doge.png").data, N = 512, particle_color = map(x->RGBA{U8}(x.r, x.g, x.b, 1.), colormap("Blues", N))

s = Vec2f0(20)
# 2D particles
particle_data2D(i, N) = Point2f0[rand(Point2f0, -10f0:eps(Float32):10f0) for x=1:N]
const p2ddata = foldp(+, Point2f0[rand(Point2f0, 0f0:eps(Float32):500f0) for x=1:N],
	const_lift(particle_data2D, bounce(1f0:1f0:50f0), N))
particle_robj = visualize(p2ddata, scale=s)




push!(TEST_DATA2D, particle_robj)
pos = particle_robj.children[][:position]
push!(TEST_DATA2D, visualize(pos, scale=s, shape=Cint(ROUNDED_RECTANGLE), color=particle_color))
push!(TEST_DATA2D, visualize(pos, scale=s, shape=Cint(CIRCLE)))
push!(TEST_DATA2D, visualize(pos, scale=s, shape=Cint(RECTANGLE)))
push!(TEST_DATA2D, visualize(pos, scale=s, shape=Cint(ROUNDED_RECTANGLE)))

push!(TEST_DATA2D, visualize(
	pos,
	shape=Cint(ROUNDED_RECTANGLE),
	image=gif, scale=Vec2f0(60)),
)
end
#=
curve_data(i) = Point2f0[Point2f0(sin(x/i)*250, x) for x=1:1024]
push!(TEST_DATA2D, visualize(const_lift(curve_data, bounce(20f0:0.1f0:1024f0)), :lines))

# text
include("utf8_example_text.jl")
push!(TEST_DATA2D, visualize(utf8_example_text))
=#
