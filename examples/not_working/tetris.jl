const O = false
const X = true
shapes = Matrix{Bool}[
    [X X X X],

    [O X O;
     X X X],

    [O O X;
     X X X],

    [O X;
     X X;
     X O],

    [X X;
     X X]
]

function to_particle(shape, particles)
    particles = Point2f0[]
    m,n = size(shape)
    for i=1:m,j=1:n
        elem && push!(particles, Point2f0(i,j))
    end
    particles
end
function update_position(p, dir, occupied) # --> shouldmove, reachedbuttom
    if ceil(p) - p > eps(Float32) # close to border
        newpos = p+dir
        x,y = round(Int, newpos)
        if checkbounds(Bool, occupied, x,y)
            if !occupied[x,y]
                occupied[x,y] = true
                return true, false
            else
                return false, true
            end
        else
            false, newpos[2] < 0
        end
    end
    true, false
end

function update_position(direction)
    shouldmove = false
    for p in particle
        move, hitbottom = update_position(p, dir, occupied)
        hitbottom && return push!(bottomed, particles)
        shouldmove = shouldmove && move
    end
    if shouldmove
        for i=1:4
            particle[i] += direction
        end
    end
end

function update_bottomed(p)
    for p in particles
        x,y = round(Int, p)
        line = size(a, 1)
        should_remove = reduce(AND, sub(a, 1:line, y))
        if should_remove
            k = y
            while reduce(AND, sub(a, 1:line, k))
                occupied[1:line, i] = occupied[1:line, i+1]
                k += 1
            end
        end
    end
end



function setup(N,M)
    fields_position = Array{Point2f0}(N,M)
    fields_occupied = Array{Bool}(N,M)
end
