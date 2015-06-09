using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes, MeshIO, Meshes, FileIO
using GLFW, ModernGL

global const T 	= Float32
const inputs 	= GLVisualize.ROOT_SCREEN.inputs

const mouse_hover = lift(first,GLVisualize.SELECTION[:mouse_hover])
function mousedragg_fold(t0, mouse_down1, mouseposition1, objectid)
	mouse_down0, draggstart, objectidstart, mouseposition0, objectid0 = t0
	if !mouse_down0 && mouse_down1
		return (mouse_down1, mouseposition1, objectid, mouseposition1, objectid)
	elseif mouse_down0 && mouse_down1
		return (mouse_down1, draggstart, objectidstart, mouseposition1, objectid)
	end
	(false, Vec2(0), Vector2(0), Vec2(0), Vector2(0))
end
isnotempty(x) = !isempty(x)
function diff_mouse(mouse_down_draggstart_mouseposition)
	mouse_down, draggstart, objectid_start, mouseposition, objectid_end = mouse_down_draggstart_mouseposition
	(draggstart - mouseposition, objectid_start, objectid_end)
end
function get_drag_diff(inputs)
	@materialize mousebuttonspressed, mousereleased, mouseposition = inputs
	mousedown = lift(isnotempty, mousebuttonspressed)
	mousedraggdiff = lift(diff_mouse, 
						foldl(mousedragg_fold, (false, Vec2(0), Vector2(0), Vec2(0), Vector2(0)), mousedown, mouseposition, mouse_hover))
	return keepwhen(mousedown, (Vec2(0), Vector2(0), Vector2(0)), mousedraggdiff)
end


const dragdiff_id = get_drag_diff(inputs)

alphabet ="abcdefghijklmnopqrstuvw"
t = join([join(["$a$i" for i=1:20]) for a=alphabet], "\n")

text 		= visualize(t, styles=Texture([RGBAU8(0,0,0,1), RGBAU8(0,0,1,1)]))
background 	= visualize(text[:positions], technique=:square, color=RGBA(0f0,0f0,0f0,0.1f0), scale=Vec2(19,32))


function text_bg_selection(selection)
	_, id_start, current_id = selection
	id_start[1] == background.id #
end
function selection_range(v0, selection)
	mousediff, id_start, current_id = selection
	if mousediff != Vec2(0)
		if current_id[1] == background.id
			return min(id_start[2],current_id[2]):max(id_start[2],current_id[2])
		end
	else
		if current_id[1] == background.id
			return current_id[2]:0 # this is the type stable way of indicating, that the selection is between currend_index
		end
	end
	v0
end
mousedown 		= lift(isnotempty, inputs[:mousebuttonspressed])

is_text_bg(id) 	= id[1] == background.id
text_selection 	= filter(text_bg_selection, (Vec2(0), Vector2(0), Vector2(0)), dragdiff_id)
selection 		= foldl(selection_range, 0:0, text_selection)

function next_newline(text, i)
	char = text[i]
	while i < length(text) && text[i] != '\n'
		i = nextind(text, i)
	end
	i
end
function previous_newline(text, i)
	char = text[i]
	while i > 0 && text[i] != '\n'
		i = prevind(text, i)
	end
	i
end
function find_next_after_nl(index, text)
	last_newline_pos = 0
	i 	= chr2ind(text, index)
	pnl = previous_newline(text, i)
	nnl = next_newline(text, i)
	nl_distance = i-pnl # distance from previous newline
	min(length(text), nnl+nl_distance)
end
function find_previous_after_nl(index, text)
	last_newline_pos = 0
	i 	 = chr2ind(text, index)
	pnl  = previous_newline(text, i)
	ppnl = previous_newline(text, pnl)
	nl_distance = i-pnl # distance from previous newline
	min(length(text), ppnl+nl_distance)
end
function move_cursor(t0, mouseselection, dir, text)
	mouseselection0, selection0 = t0
	mouseselection0 != mouseselection && return (mouseselection, mouseselection)
	if selection0 != 0:0
		last_i = isempty(selection0) ? first(selection0) : last(selection0) # if only single char selected use first, otherwise last position of selection
		if dir == :up
			return (mouseselection, find_previous_after_nl(first(selection0), text):0)  #:0 -> movement changes selection into single point selection
		elseif dir == :down
			return (mouseselection, find_next_after_nl(last_i, text):0)
		elseif dir == :left
			return (mouseselection, max(1,first(selection0)-1):0)
		elseif dir == :right
			return (mouseselection, min(length(text),last_i+1):0)
		end
	end
	t0
end

function to_arrow_symbol(button)
	isempty(button) && return :nothing
	first(button) == GLFW.KEY_RIGHT && return :right
	first(button) == GLFW.KEY_LEFT && return :left
	first(button) == GLFW.KEY_DOWN && return :down
	first(button) == GLFW.KEY_UP && return :up
end
arrow_navigation = lift(to_arrow_symbol, inputs[:buttonspressed])
selection = lift(last, foldl(move_cursor, (selection.value, selection.value), selection, arrow_navigation, Input(t)))

cursor_visible(range) = isempty(range) && first(range) > 0
function cursor(positions, screen, range)
    camera = screen.orthographiccam
    atlas = GLVisualize.get_texture_atlas()
    data = merge(Dict(
    	:visible 			 => lift(cursor_visible, range),
        :offset 			 => lift(Cint, lift(first, range)),
        :positions           => positions,
        :glyph               => Sprite{GLuint}(GLVisualize.get_font!('|')),
        :uvs                 => atlas.attributes,
        :images              => atlas.images,
        :style_index         => SpriteStyle{GLuint}(0,0),
        :projectionviewmodel => camera.projectionview,

    ), collect_for_gl(GLMesh2D(Rectangle(0f0, 0f0, 1f0, 1f0))))

    shader = TemplateProgram(
        File(GLVisualize.shaderdir, "util.vert"), 
        File(GLVisualize.shaderdir, "text_single.vert"), 
        File(GLVisualize.shaderdir, "text.frag")
    )
    std_renderobject(data, shader)
end

function edit_text(selection0, selection)
	tgpua = text[:style_index]
	#println("selection0: ", selection0)
	#println("selection: ", selection)
	if first(selection0) != 0 && last(selection0) != 0 && !isempty(selection0)
		tgpua[selection0] = fill(GLVisualize.GLSpriteStyle(0,0), length(selection0))
	end
	if first(selection) != 0 && last(selection) != 0 && !isempty(selection)
		tgpua[selection] = fill(GLVisualize.GLSpriteStyle(1,0), length(selection))
	end
	selection
end

foldl(edit_text, 0:0, selection)
push!(GLVisualize.ROOT_SCREEN.renderlist, background)
push!(GLVisualize.ROOT_SCREEN.renderlist, text)
push!(GLVisualize.ROOT_SCREEN.renderlist, cursor(text[:positions], GLVisualize.ROOT_SCREEN, selection))
renderloop()