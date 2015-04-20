TEXT_EDIT_DEFAULTS = @compat Dict{Symbol, Any}(
:Default => @compat Dict{Symbol, Any}(
	:model           => eye(Mat4),
	:screen          => ROOT_SCREEN

))
edit(text::String, style=Style(:Default); customization...) = edit(style, text, mergedefault!(style, TEXT_EDIT_DEFAULTS, customization))
edit(text::Texture{GLGlyph{Uint16}, 2}, obj::RenderObject, style=Style(:Default); customization...) = edit(style, text, obj, mergedefault!(style, TEXT_EDIT_DEFAULTS, customization))




MATRIX_EDITING_DEFAULTS = @compat(Dict(
:Default => @compat(Dict(
	:offset 	     => Vec2(0),
	:backgroundcolor => rgba(0,0,0.4, 0.3),
	:color           => rgba(248.0/255.0, 248.0/255.0,242.0/255.0, 1.0),
	:maxdigits       => 5f0,
	:maxlength       => 10f0, 
	:model           => eye(Mat4),
	:screen          => ROOT_SCREEN,
	:font            => getfont(),
	:newline         => -Vec3(0, getfont().props[1][2]*1.5f0, 0),
	:advance         => Vec3(getfont().props[1][1], 0, 0)
))
))
# High Level text rendering for one line or multi line text, which is decided by searching for the occurence of '\n' in text
# Low level text rendering for one line text
# Low level text rendering for multiple line text
edit{T <: Union(FixedVector, Real)}(numbers::Texture{T, 2}, style=Style(:Default); customization...) = edit(style, numbers, mergedefault!(style, MATRIX_EDITING_DEFAULTS, customization))
edit{T <: Union(AbstractVector, Real)}(numbers::Input{T}, 			   style=Style(:Default); customization...) = edit(numbers.value, style; customization...)
edit{T <: Union(AbstractVector, Real)}(numbers::T, 					   style=Style(:Default); customization...) = edit(style, numbers, mergedefault!(style, MATRIX_EDITING_DEFAULTS, customization))


RENDEROBJECT_DEFAULTS = @compat Dict{Symbol, Any}(
:Default => @compat Dict{Symbol, Any}(
  :model           => eye(Mat4),
  :screen          => ROOT_SCREEN
))
edit(obj::RenderObject, style=Style(:Default); customizations...) = edit(style, obj, mergedefault!(style, RENDEROBJECT_DEFAULTS, customizations))


#################################################################################################################################
# Color Editing:
edit(color::AbstractAlphaColor, style::Style=Style(:Default); customization...) = visualize(color, style; customization...) 
