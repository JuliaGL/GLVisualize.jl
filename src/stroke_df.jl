# functions to generate distance fields for stroke types
function circle{T}(uv::Vec{2,T})
    T(1)-norm(uv)
end

function dots(gap, resolution)
    X = linspace(0, gap, resolution[1])
    Y = linspace(0, 1, resolution[2])
    Float16[
        circle(Vec(x-0.5,y-0.5))
    for x=X, y=Y]
end


dist(a, b) = abs(a-b)
mindist(x, a, b) = min(dist(a, x), dist(b, x))
function gappy(x, ps)
    n = length(ps)
    x <= first(ps) && return first(ps) - x
    for j=1:(n-1)
        p0 = ps[j]
        p1 = ps[min(j+1, n)]
        if p0 <= x && p1 >= x
            return mindist(x, p0, p1) * (isodd(j) ? 1 : -1)
        end
    end
    return last(ps) - x
end
function ticks(points, resolution)
    Float16[gappy(x, points) for x=linspace(first(points),last(points), resolution)]
end

points = [0., 0.01, 0.02, 0.03, 0.09, 0.6, 0.8, 0.9]


text = Texture(ticks(points, 100), x_repeat=:repeat)
