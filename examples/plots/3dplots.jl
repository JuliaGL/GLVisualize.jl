using Plots, GLVisualize, GeometryTypes, Colors

pl_size = if !isempty(GLVisualize.get_screens())
    widths(GLVisualize.current_screen())
else
    (1000, 1000)
end
glvisualize(size = pl_size)

description = """
How to create different 3D plots with Plots.jl
"""

function lorenz(t0, a, b, c, h)
    Point3f0(
        t0[1] + h * a * (t0[2] - t0[1]),
        t0[2] + h * (t0[1] * (b - t0[3]) - t0[2]),
        t0[3] + h * (t0[1] * t0[2] - c * t0[3]),
    )
end
# step through the `time`
function lorenz(array::Vector, a=5.0,b=2.0,c=6.0,d=0.01)
    t0 = Point3f0(0.1, 0, 0)
    for i = eachindex(array)
        t0 = lorenz(t0, a,b,c,d)
        array[i] = t0
    end
    array
end

N = 1000
xyz = lorenz(zeros(Point3f0, N), 26., 28., 9.0, 0.01)
x,y,z = map(first, xyz), map(x-> x[2], xyz), map(last, xyz)
p1 = plot(x,y,z,
    line=0.5,
    marker=(:circle, 0.4), ms = linspace(2.0, 10.0, N),
    markercolor = colormap("RdBu", N),
    leg = false,
    grid = false
)

dphi, dtheta = pi/200.0f0, pi/200.0f0
function mgrid(dim1, dim2)
    X = [i for i in dim1, j in dim2]
    Y = [j for i in dim1, j in dim2]
    return X,Y
end

phi,theta = mgrid(0f0:dphi:(pi+dphi*1.5f0), 0f0:dtheta:(2f0*pi+dtheta*1.5f0));
m0 = 4f0; m1 = 3f0; m2 = 2f0; m3 = 3f0; m4 = 6f0; m5 = 2f0; m6 = 6f0; m7 = 4f0;
a = sin.(m0*phi).^m1;
b = cos.(m2*phi).^m3;
c = sin.(m4*theta).^m5;
d = cos.(m6*theta).^m7;
r = a + b + c + d;
x = r.*sin.(phi).*cos.(theta);
y = r.*cos.(phi);
z = r.*sin.(phi).*sin.(theta);
surface1 = Plots.surface(x,y,z)


function xy_data(x, y, i, N)
    x = ((x / N)-0.5) * i
    y = ((y / N)-0.5) * i
    r = sqrt(x * x + y * y)
    sin(r) / r
end

surface2 = Plots.surface(Float32[xy_data(x, y, 20f0, N) for x=1:100, y=1:100])
surface3 = Plots.wireframe(
    Float32[xy_data(x * 10, y * 10, 40f0, N) for x=1:30, y=1:30],
    line = 4.0
)

p = plot(surface1, surface2, surface3, p1, show = true)

gui()
