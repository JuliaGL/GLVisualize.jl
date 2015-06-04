vectorfielddata(N) = return Vec3[Vec3(cos(x/10)+x^2, cos(y/10)+y^2, cos(z/10)+z^2) for x=1:N,y=1:N, z=1:N]
	
push!(TEST_DATA, vectorfielddata(14))

