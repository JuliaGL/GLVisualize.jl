using GLVisualize, GLAbstraction, GeometryTypes, Reactive

if !isdefined(:runtests)
	window = glscreen()
    timesignal = loop(linspace(0f0,1f0,360))
end

function mgrid(dim1, dim2)
    X = [i for i in dim1, j in dim2]
    Y = [j for i in dim1, j in dim2]
    return X,Y
end


rotation_angle = const_lift(*, timesignal, 2f0*pi)
rotation = map(rotationmatrix_z, rotation_angle)

dphi, dtheta = pi/200.0f0, pi/200.0f0

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


surface = visualize((x,y,z), :surface, model=rotation)
_view(surface, window)


if !isdefined(:runtests)
	renderloop(window)
end
