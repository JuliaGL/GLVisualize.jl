using GLVisualize, GeometryTypes, Colors, GLAbstraction

if !isdefined(:runtests)
    window = glscreen()
    timesignal = loop(linspace(0f0, 1f0, 360))
end

description = """
Animating text particles color, scale and rotation.
"""

# Did we mention, that text is just a normal sprite particle system?
# This means, it supports all the attributes like the other particle systems.

# some text again
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

# create a rotation from the time signal
rotation = map(timesignal) do t
    t2π = t*pi*2
    Vec3f0(cos(t2π),sin(t2π), 1)
end

# create some funcy scale change
scale = map(timesignal) do t
    circular = sin(t*pi)
    (1 + circular * 0.5) * 20f0
end
const len = length(s)

# per glyph color
color = map(timesignal) do t
    RGBA{Float32}[RGBA{Float32}(i/len,1, (sin(t)+1.)/2., 1) for i=1:len]
end

# per glyph stroke color
stroke_color = RGBA{Float32}[RGBA{Float32}(0,0,0, i/len) for i=1:len]

# _view and visualize it!
# you could also pass positions as a keyword argument or make
# the scale/rotation per glyph by supplying a Vector of them.
textvizz = visualize(s,
    model = translationmatrix(Vec3f0(0,600,0)), # move this up, since the text starts at 0 and goes down from there
    rotation = rotation,
    color = color,
    stroke_color = stroke_color,
    stroke_width = 1f0,
    relative_scale = scale
)

_view(textvizz, window)

if !isdefined(:runtests)
    renderloop(window)
end
