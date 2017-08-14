using GeometryTypes, GLVisualize, GLAbstraction, ImageMagick
using FileIO, ColorTypes, Reactive

if !isdefined(:runtests)
    window = glscreen()
end
const description = """
You can move mario around with the arrow keys
"""
const record_interactive = true

mutable struct Mario{T}
    x             ::T
    y             ::T
    vx            ::T
    vy            ::T
    direction     ::Symbol
end



gravity(dt, mario) = (mario.vy = (mario.y > 0.0 ? mario.vy - (dt/4.0) : 0.0); mario)

function physics(dt, mario)
    mario.x = mario.x + dt * mario.vx
    mario.y    = max(0.0, mario.y + dt * mario.vy)
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
    mario = jump(keys,     mario)
    mario = walk(keys,     mario)
    mario = physics(dt, mario)
    mario
end



mario2model(mario) = translationmatrix(Vec3f0(mario.x, mario.y, 0f0))*scalematrix(Vec3f0(5f0))

const mario_images = Dict()


function play(x::Vector)
    const_lift(getindex, x, loop(1:length(x)))
end

function read_sequence(path)
    if isdir(path)
        return map(load, sort(map(x->joinpath(path, x), readdir(path))))
    else
        return fill(load(path), 1)
    end
end

for verb in ["jump", "walk", "stand"], dir in ["left", "right"]
    pic = dir
    if verb != "walk" # not a sequemce
        pic *= ".png"
    end
    path = assetpath("mario", verb, pic)
    sequence = read_sequence(path)
    gif = map(img->convert(Matrix{RGBA{N0f8}}, img), sequence)
    mario_images[verb*dir] = play(gif)
end
function mario2image(mario, images=mario_images)
    verb = mario.y > 0.0 ? "jump" : mario.vx != 0.0 ? "walk" : "stand"
    mario_images[verb*string(mario.direction)].value # is a signal of pictures itself (animation), so .value samples the current image
end
function arrows2vec(direction)
    direction == :up     && return Vec2f0( 0.0,  1.0)
    direction == :down     && return Vec2f0( 0.0, -1.0)
    direction == :right && return Vec2f0( 3.0,  0.0)
    direction == :left     && return Vec2f0(-3.0,  0.0)
    Vec2f0(0.0)
end

# Put everything together
arrows             = sampleon(bounce(1:10), window.inputs[:arrow_navigation])
keys             = const_lift(arrows2vec, arrows)
mario_signal     = const_lift(update, 8.0, keys, Mario(0.0, 0.0, 0.0, 0.0, :right))
image_stream     = const_lift(mario2image, mario_signal)
modelmatrix     = const_lift(mario2model, mario_signal)

mario = visualize(image_stream, model=modelmatrix)

_view(mario, window, camera=:fixed_pixel)

if !isdefined(:runtests)
    renderloop(window)
end
