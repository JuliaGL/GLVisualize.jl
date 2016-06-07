using GLVisualize, GeometryTypes, Colors, GLAbstraction

if !isdefined(:runtests)
	window = glscreen()
	timesignal = bounce(linspace(0,1,20))
end

# GLAbstraction.const_lift is defined as
# const_lift(F, args...) = Reactive.map(F, map(Signal, args)...)
# and allows to also use constant arguments without manually wrapping
# them into signals
π_signal = const_lift(*, timesignal, pi)

# Reactive.map takes a signal and transforms it by applying F into a new signal
# it's similar to Base.map, just over the time dimension (like registering a
# callback in a more traditional event system)
s = """The quick brown fox jumped over
some lazy text sample.
He wasn't really into numbers, but it's
really important to try out number rendering:
This number goes from 0 to π in no time!
And then back to 0 again... Wow!
This is real crazy stuff,
but it gets even more ludicrous:
∮ E⋅da = Q,  n → ∞, ∑ f(i) = ∏ g(i),
∀x∈ℝ: ⌈x⌉ = −⌊−x⌋, α ∧ ¬β = ¬(¬α ∨ β),
ℕ ⊆ ℕ₀ ⊂ ℤ ⊂ ℚ ⊂ ℝ ⊂ ℂ,
⊥ < a ≠ b ≡ c ≤ d ≪ ⊤ ⇒ (A ⇔ B),
2H₂ + O₂ ⇌ 2H₂O, R = 4.7 kΩ, ⌀
I can't even...
"""

# view and visualize it!
view(visualize(s,
    model=translationmatrix(Vec3f0(0,600,0)), # move this up, since the text starts at 0 and goes down from there
    color=fill(RGBA{Float32}(0,1,0,0.8), length((s))),
    relative_scale=Vec2f0(1),
    rotation = Vec3f0(0,0, 1),
    stroke_width = 1f0,
    stroke_color=RGBA{Float32}(0,1,0,0.8),
), window)

if !isdefined(:runtests)
	renderloop(window)
end
