eval(:( 
	module Test 
		include("inc.jl")
	end
))

println(Test.X)
