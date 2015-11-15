using GeometryTypes, GLVisualize, GLAbstraction, GeometryTypes, ImageMagick, FileIO, ColorTypes, Reactive
w, r = glscreen()
type Mario{T}
    x 			::T
    y 			::T
    vx 			::T
    vy 			::T
    direction 	::Symbol
end

gravity(dt, mario) = (mario.vy = (mario.y > 0.0 ? mario.vy - (dt/4.0) : 0.0); mario)

function physics(dt, mario)
    mario.x = mario.x + dt * mario.vx
    mario.y	= max(0.0, mario.y + dt * mario.vy)
    mario
end

function walk(keys, mario)
    mario.vx = keys[1]
    mario.direction = keys[1] < 0.0 ? :left : keys[1] > 0.0 ? :right : mario.direction
    mario
end

function jump(keys, mario)
    if keys[2] > 0.0 && mario.vy == 0.0 
    	mario.vy = 6.0
    end
	mario
end

function update(dt, keys, mario)
    mario = gravity(dt, mario)
    mario = jump(keys, 	mario)
    mario = walk(keys, 	mario)
    mario = physics(dt, mario)
    mario
end



mario2model(mario) = translationmatrix(Vec3f0(mario.x, mario.y, 0f0))*scalematrix(Vec3f0(5f0))

const mario_images = Dict()


play{T}(array::Array{T, 3}, slice) = array[:, :, slice]
	

signify{T}(x::Array{T, 2}) = Signal(x)
function signify{T}(x::Array{T, 3})
	const_lift(play, x, loop(1:size(x, 3)))
end

bgra{T}(rgb::RGB{T}) 		= BGRA(rgb.b, rgb.g, rgb.r, one(T))
bgra{T}(rgb::Array{RGB{T}}) = map(bgra, rgb)
bgra(rgb) = rgb
for verb in ["jump", "walk", "stand"], dir in ["left", "right"]
	gif = bgra(load(joinpath("imgs", "mario", verb, dir*".gif")).data)
	mario_images[verb*dir] = signify(gif)
end
function mario2image(mario, images=mario_images) 
	verb = mario.y > 0.0 ? "jump" : mario.vx != 0.0 ? "walk" : "stand"
	mario_images[verb*string(mario.direction)].value # is a signal of pictures itself (animation), so .value samples the current image
end
function arrows2vec(direction)
	direction == :up 	&& return Vec2f0( 0.0,  1.0)
	direction == :down 	&& return Vec2f0( 0.0, -1.0)
	direction == :right && return Vec2f0( 3.0,  0.0)
	direction == :left 	&& return Vec2f0(-3.0,  0.0)
	Vec2f0(0.0)
end

# Put everything together
arrows 			= sampleon(bounce(1:10), GLVisualize.ROOT_SCREEN.inputs[:arrow_navigation])
keys 			= const_lift(arrows2vec, arrows) 
mario_signal 	= const_lift(update, 8.0, keys, Mario(0.0, 0.0, 0.0, 0.0, :right))
image_stream 	= const_lift(mario2image, mario_signal)
modelmatrix 	= const_lift(mario2model, mario_signal)

view(visualize(image_stream, model=modelmatrix))
  
r()