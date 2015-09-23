isnewline(x) = x[1] == UInt16('\n')
# i must be a valid character index
function next_newline(text, i::Integer)
	res = findnext(isnewline, text, i)
	res == 0 ? length(text) : res
end
previous_newline(text, i::Integer) = max(1, findprev(isnewline, text, i))

export previous_newline
export next_newline



#=
textextetext\n
texttext<current pos>texttext\n
texttext<finds this pos>text\n
=#
function down_after_newline(text, current_position)
	i 	= current_position
	pnl = previous_newline(text, i)
	nnl = next_newline(text, i)
	nl_distance = i-pnl # distance from previous newline
	min(length(text), nnl+nl_distance)
end
#=
textexte<finds this pos>text\n
texttext<current pos>texttext\n
texttexttext\n
=#
function up_before_newline(text, current_position)
	i 	 = current_position
	pnl  = previous_newline(text, i)
	ppnl = previous_newline(text, max(1, pnl-1))
	nl_distance = i-pnl # distance from previous newline
	min(length(text), ppnl+nl_distance)
end

function next_arrow_selection(dir, text, first_index, last_index)
	(dir == :up)    && return up_before_newline(text, first_index)
	(dir == :down)  && return down_after_newline(text, last_index)
	(dir == :left)  && return max(1, first_index-1)
	(dir == :right) && return min(length(text)+1, last_index+1)
    -1
end

function move_cursor(t0, dir, mouseselection, text_selection, is_movingselection)
	text, selection = text_selection.text, text_selection.selection
	mouseselection0, selection0 = t0
	selection0 = selection
	mouseselection0 != mouseselection && return (mouseselection, mouseselection) # if mouse selection has changed, return the new position
	if selection0 != 0:0
		first_i   = first(selection0) # first is always valid, if its not zero
		# last is not valid, if selection is in between characters
		last_i    = isempty(selection0) ? first(selection0) : last(selection0) # if only single char selected use first, otherwise last position of selection
		nas       = next_arrow_selection(dir, text, first_i, last_i) # -1 for no new arrow selection
        if nas != -1
            if is_movingselection
                return (mouseselection, nas:last_i)
            else
                return (mouseselection, nas:0)
            end
        end
	end
	(mouseselection0, selection0)
end
export move_cursor


function visualize_selection(
		last_selection::UnitRange{Int}, 
		selection 	  ::UnitRange{Int},
		style 		  ::GPUVector{GLSpriteStyle}
	)
	fl, ll =  first(last_selection), last(last_selection)
	if !isempty(last_selection) && fl > 0 && ll > 0 && (fl <= length(style)) && (ll <= length(style))
		style[last_selection] = fill(GLSpriteStyle(0,0), length(last_selection))
	end
	fs, ls =  first(selection), last(selection)
	if !isempty(selection) && fs > 0 && ls > 0 && (fs <= length(style)) && (ls <= length(style))
		style[selection] = fill(GLSpriteStyle(1,0), length(selection))
	end
	selection
end


AND(a,b) 	  = a&&b
isnotempty(x) = !isempty(x)
return_nothing(x...) = nothing
export AND
export isnotempty
export return_nothing

single_selection(selection::UnitRange) 	= isempty(selection) && first(selection)!=0
is_textinput_modifiers(buttons::Vector{Int}) = isempty(buttons) || buttons == [GLFW.KEY_LEFT_SHIFT]

function clipboardpaste(_)
	clipboard_data = ""
	try
		clipboard_data = clipboard()
	catch e # clipboard throws error when there is no data (WTF)
	end
	return utf8(clipboard_data)
end

export clipboardpaste
export copyclipboard

function back2julia(x::GLSprite)
	isnewline(x[1]) && return '\n'
	ID_TO_CHAR[x[1]]
end
function Base.utf8(v::GPUVector{GLSprite})
	data = gpu_data(v)
	utf8(join(map(back2julia, data)))
end
# lift will have a boolean value at first argument position
copyclipboard(_, text_selection) = copyclipboard(text_selection)
function copyclipboard(text_selection)
	selection, text = text_selection.selection, text_selection.text
	if first(selection) > 0
		if single_selection(selection) # for single selection we do a sublime style line copy
			#i 	= chr2ind(text, first(selection))
			i 	= min(length(text), first(selection)) # can be on position behind last character
			pnl = previous_newline(text, i)
			nnl = next_newline(text, i)
			tocopy = text[pnl:nnl]
		else # must be range selection
			tocopy = text[selection]
		end
		clipboard(join(map(x->ID_TO_CHAR[x[1]], tocopy)))
	end
	nothing
end
export cutclipboard
cutclipboard(_, text_selection) = cutclipboard(text_selection)
function cutclipboard(text_selection)
	copyclipboard(text_selection)
	deletetext(text_selection)
	nothing
end
export deletetext
deletetext(_, text_selection) = deletetext(text_selection)
function deletetext(text_selection)
	selection, text = text_selection.selection, text_selection.text
	offset = 0
	if first(selection) > 0 && last(selection) > 0
		if single_selection(selection)
			splice!(text, last(selection))
			offset = -1
		else
			splice!(text, selection)
		end
		text_selection.selection = max(1, first(selection)+offset):0 # when text gets removed, selection will turn into single selection
	end
	nothing
end
export inserttext
inserttext(_, text_selection) = inserttext(text_selection)
function inserttext(text_selection, to_insert)
	selection, text = text_selection.selection, text_selection.text
	if first(selection) > 0
		splice!(text, selection, to_insert)
		chars_added = length(to_insert)
		text_selection.selection = (first(selection)+chars_added):0 # when text gets removed, selection will turn into single selection
	end
	nothing
end

type TextWithSelection{S } #<: AbstractString}
	text::S
	selection::UnitRange{Int}
end
export TextWithSelection




export visualize_selection


calc_position(glyphs::GPUVector, startposition=Vec2f0(0)) = calc_position(gpu_data(glyphs), startposition)
function calc_position(glyphs, startposition=Vec2f0(0))
	const PF16 = Point{2, Float16}
    positions = fill(PF16(0.0), length(glyphs))
	if !isempty(glyphs)
	    global FONT_EXTENDS, ID_TO_CHAR
	    last_pos  = PF16(startposition)
	    lastglyph = first(glyphs)
	    for (i,glyph) in enumerate(glyphs)
	        extent = FONT_EXTENDS[glyph[1]]
	        if isnewline(lastglyph)
	            if i<2
	                last_pos = PF16(last_pos[1], last_pos[2]-extent.advance[2])
	            else
	                last_pos = PF16(first(positions)[1], positions[i-1][2]-extent.advance[2])
	            end
	            positions[i] = last_pos
	        else
	            last_pos += PF16(extent.advance[1], 0)
	            finalpos = last_pos
	            #finalpos = PF16(last_pos.x+extent.horizontal_bearing.x, last_pos.y-(extent.scale.y-extent.horizontal_bearing.y))
	            #(i>1) && (finalpos += PF16(kerning(ID_TO_CHAR[lastglyph[1]], ID_TO_CHAR[glyph[1]], DEFAULT_FONT_FACE, 64f0)))
	            positions[i] = finalpos
	        end
	        lastglyph = glyph
	    end
	end
    positions
end

export process_for_gl

function process_for_gl(text, tabs=4)
	result = GLSprite[]
	sizehint!(result, length(text))
	for elem in text
		if elem == '\t'
			space = get_font!(' ')
			append!(result, fill(GLSprite(space), tabs))
		elseif elem == '\r'
			#don't add
		elseif elem == '\n'
			nl = get_font!('\n')
			push!(result, GLSprite(nl))
		else
			push!(result, GLSprite(get_font!(elem)))
		end
	end
	return result
end