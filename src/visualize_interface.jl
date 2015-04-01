visualize(x; customizations...) = visualize(string(x); customizations...)
visualize(x::Function; customizations...) = visualize(methods(x); customizations...)


#################################################################################################################################
#Text Rendering:
TEXT_DEFAULTS = @compat Dict(
:Default => @compat Dict(
  :start            => Vec3(0.0),
  :offset           => Vec2(1.0, 1.5), #Multiplicator for advance, newline
  :color            => rgba(248.0/255.0, 248.0/255.0,242.0/255.0, 1.0),
  :backgroundcolor  => rgba(0,0,0,0),
  :model            => eye(Mat4),
  :newline          => -Vec3(0, getfont().props[1][2], 0),
  :advance          => Vec3(getfont().props[1][1], 0, 0),
  :screen           => ROOT_SCREEN,
  :font             => getfont(),
  :stride           => 1024
))

# High Level text rendering for one line or multi line text, which is decided by searching for the occurence of '\n' in text
visualize(text::String,                           style::Style=Style(:Default); customization...) = visualize(style, text, mergedefault!(style, TEXT_DEFAULTS, customization))
# Low level text rendering for multiple line text
visualize(text::Texture{GLGlyph{Uint16}, 4, 2},   style::Style=Style(:Default); customization...) = visualize(style, text, mergedefault!(style, TEXT_DEFAULTS, customization))
visualize(text::Vector{GLGlyph{Uint16}},          style::Style=Style(:Default); customization...) = visualize(style, text, mergedefault!(style, TEXT_DEFAULTS, customization))
visualize(text::Matrix{GLGlyph{Uint16}},          style::Style=Style(:Default); customization...) = visualize(style, text, mergedefault!(style, TEXT_DEFAULTS, customization))

# END Text Rendering
#################################################################################################################################

#################################################################################################################################
#Surface Rendering:

SURFACE_DEFAULTS = @compat Dict(
:Default => @compat Dict(
    :primitive      => SURFACE(),     # can also be CUBES(), CIRCLES(), POINT()
    :x              => (-1,1),        # can also be a matrix
    :y              => (-1,1),        # can also be a matrix
    :color          => rgba(1,0,0,1), # can also be Array/Texture{RGB/RGBA, 1/2}, with "/" meaning OR. 
                                      # A 1D Array of color values is assumed to be a colormap.
                                      # A 2D Array can have higher or lower resolution, and will be automatically mapped on the data points.
    :light_position => Vec3(20, 20, -20), 

    :screen         => ROOT_SCREEN,
    :model          => eye(Mat4),
))

begin 
local PointType = Union(AbstractFixedVector, Real)
# Visualizes a matrix of 1D Values as a surface, whereas the values get interpreted as z-values
visualize{T <: PointType}(zpoints::Matrix{T},        attribute = :z,  style::Style=Style(:Default); customization...) = visualize(style, zpoints, attribute, mergedefault!(style, SURFACE_DEFAULTS, customization))
visualize{T <: PointType}(zpoints::Texture{T, 1, 2}, attribute = :z,  style::Style=Style(:Default); customization...) = visualize(style, zpoints, attribute, mergedefault!(style, SURFACE_DEFAULTS, customization))
visualize{T <: PointType}(x::Matrix{T}, y::Matrix{T}, z::Matrix{T},   style::Style=Style(:Default); customization...) = visualize(style, zpoints, attribute, mergedefault!(style, SURFACE_DEFAULTS, customization))
end
# END Surface Rendering
#################################################################################################################################


#################################################################################################################################
# Image Rendering:
IMAGE_DEFAULTS = @compat(Dict(
:Default => @compat(Dict(
    :normrange      => Vec2(0,1),   # stretch the value 0-1 to normrange: normrange.x + (color * (normrange.y - normrange.x))
    :kernel         => 1f0,         # kernel can be a matrix or a float, whereas the float gets interpreted as a multiplicator
    :model          => eye(Mat4),
    :screen         => ROOT_SCREEN,
    :model          => eye(Mat4),
)),
:GaussFiltered => @compat(Dict(
    :normrange      => Vec2(0,1),   # stretch the value 0-1 to normrange: normrange.x + (color * (normrange.y - normrange.x))
    :kernel         => Float32[1 2 1; 2 4 2; 1 2 1] / 16f0,         # kernel can be a matrix or a float, whereas the float gets interpreted as a multiplicator
    :model          => eye(Mat4),
    :screen         => ROOT_SCREEN,
    :model          => eye(Mat4),
)),
:LaPlace => @compat(Dict(
    :normrange      => Vec2(0,1),   # stretch the value 0-1 to normrange: normrange.x + (color * (normrange.y - normrange.x))
    :kernel         => Float32[-1 -1 -1; -1 9 -1; -1 -1 -1],         # kernel can be a matrix or a float, whereas the float gets interpreted as a multiplicator
    :model          => eye(Mat4),
    :screen         => ROOT_SCREEN,
    :model          => eye(Mat4),
))))
begin 
local PixelType = Union(ColorValue, AbstractAlphaColorValue, Images.ColorTypes.AlphaColor)
visualize{T <: PixelType, CDim}(image::Texture{T, CDim, 2}, style::Style=Style(:Default); customization...) = visualize(style, image, mergedefault!(style, IMAGE_DEFAULTS, customization))
end

# END Image Rendering
#################################################################################################################################

#################################################################################################################################
# Volume Rendering:
VOLUME_DEFAULTS = @compat(Dict(
:Default => @compat(Dict(
  :spacing        => [1f0, 1f0, 1f0], 
  :stepsize       => 0.001f0,
  :isovalue       => 0.5f0, 
  :algorithm      => 1f0, 
  :color          => Vec3(0,0,1), 
  :light_position => Vec3(2, 2, -2),
  :model          => eye(Mat4),
  :screen         => ROOT_SCREEN
))
))
begin 
local PointType = Union(RGB, Real, RGBA)
visualize{T <: PointType}(intensities::Array{T, 3},         style::Style=Style(:Default); customization...) = visualize(style, intensities, mergedefault!(style, VOLUME_DEFAULTS, customization))
visualize{T <: PointType}(intensities::Image{T, 3},         style::Style=Style(:Default); customization...) = visualize(style, intensities, mergedefault!(style, VOLUME_DEFAULTS, customization))
visualize{T <: PointType}(intensities::Texture{T, 1, 3},    style::Style=Style(:Default); customization...) = visualize(style, intensities, mergedefault!(style, VOLUME_DEFAULTS, customization))
end
# END Volume Rendering
#################################################################################################################################

#################################################################################################################################
# Color Rendering:
COLOR_DEFAULTS = @compat(Dict(
:Default => @compat(Dict(
  :screen                   => ROOT_SCREEN,
  :middle                   => Vec2(0.5),

  :swatchsize               => 0.1f0,
  :border_color             => rgba(1, 1, 0.99, 1),
  :border_size              => 0.02f0,

  :hover                    => Input(false),
  :hue_saturation           => Input(false),
  :brightness_transparency  => Input(false),
  :antialiasing_value       => 0.01f0,
  :model                    => scalematrix(Vec3(200,200,1))
))
))
visualize(color::AbstractAlphaColorValue, style::Style=Style(:Default); customization...) = visualize(style, color, mergedefault!(style, COLOR_DEFAULTS, customization)) 

# END Color Rendering
#################################################################################################################################

