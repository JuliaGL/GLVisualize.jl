isnewline(x::Char) = x =='\n'
# i must be a valid character index
next_newline(text::AbstractString, i::Integer) = findnext(isnewline, text, i)
previous_newline(text::AbstractString, i::Integer) = findprev(isnewline, text, i)
#=
textextetext\n
texttext<current pos>texttext\n
texttext<finds this pos>text\n
=#
function down_after_newline(text, current_position)
	i 	= chr2ind(text, current_position)
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
	i 	 = chr2ind(text, current_position)
	pnl  = previous_newline(text, i)
	ppnl = previous_newline(text, max(1, pnl-1))
	nl_distance = i-pnl # distance from previous newline
	min(length(text), ppnl+nl_distance)
end
function move_cursor(t0, mouseselection, dir, text)
	mouseselection0, selection0 = t0
	mouseselection0 != mouseselection && return (mouseselection, mouseselection) # if mouse selection has changed, return the new position
	if selection0 != 0:0
		first_i = first(selection0) # first is always valid, if its not zero
		# last is not valid, if selection is in between characters
		last_i = isempty(selection0) ? first(selection0) : last(selection0) # if only single char selected use first, otherwise last position of selection
		if dir == :up
			return (mouseselection, up_before_newline(text, first_i):0)  #:0 -> movement changes selection into single point selection
		elseif dir == :down
			return (mouseselection, down_after_newline(text, last_i):0)
		elseif dir == :left
			return (mouseselection, max(1, first_i-1):0)
		elseif dir == :right
			return (mouseselection, min(length(text),last_i+1):0)
		end
	end
	t0
end
export move_cursor



function visualize_selection(
		last_selection::UnitRange{Int}, 
		selection 	  ::UnitRange{Int},
		style 		  ::Texture{GLSpriteStyle, 1}
	)
	if first(last_selection) != 0 && last(last_selection) != 0 && !isempty(last_selection)
		style[last_selection] = fill(GLSpriteStyle(0,0), length(last_selection))
	end
	if first(selection) != 0 && last(selection) != 0 && !isempty(selection)
		style[selection] = fill(GLSpriteStyle(1,0), length(selection))
	end
	selection
end
export visualize_selection