using GLVisualize, GLAbstraction, Colors, Reactive
w,r=glscreen()
function xy_data(x,y,i, N)
	x = ((x/N)-0.5f0)*i
	y = ((y/N)-0.5f0)*i
	r = sqrt(x*x + y*y)
	Float32(sin(r)/r)
end
surf(i, N) = Float32[xy_data(Float32(x),Float32(y),Float32(i), N) for x=1:N, y=1:N]
t = Signal(20f0)
view(visualize(const_lift(surf, t, 400), :surface))
@async r()
sleep(2)
i = 1
for r=[20:80 ; 80:-1:20]
	yield() # yield to render process
	sleep(0.01)
	screenshot(w, path=joinpath(homedir(), "Videos","circles", @sprintf("frame%03d.png", i)))
    push!(t, r) # rotate around camera y axis.
	i += 1
end
