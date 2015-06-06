vectorfielddata(N, i) = Vec3[Vec3(cos(x/N*3)*i, cos(y/7i), cos(i/5)) for x=1:N, y=1:N, z=1:N]

const t = bounce(1f0:0.1f0:5f0)

push!(TEST_DATA, vectorfielddata(14, 1f0))
push!(TEST_DATA, (lift(vectorfielddata, 7, t), :norm=>Vec2(1, 5)))

