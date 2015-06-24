#this is just a temporary solution... Video IO should be integrated via FileIO
export play

function play{T}(array::Array{T, 3}, slice)
	array[:, :, slice]
end

function play{T}(buffer::Array{T, 2}, video_stream, t)
	eof(video_stream) && seekstart(video_stream)
	w,h 	= size(buffer)
	buffer 	= reinterpret(Uint8, buffer, (3, w,h))
	read!(video_stream, buffer) # looses type and shape
	return reinterpret(T, buffer, (w,h))
end
function visualize(gif::Union(File{:mp4}, File{:gif}))
	video_stream = VideoIO.openvideo(abspath(gif))
	t0 			 = read(video_stream)
	cd, w, h 	 = size(t0)
	giff 		 = foldl(play, reinterpret(RGB{Ufixed8}, t0, (w, h)), Input(video_stream), TIMER_SIGNAL)
	visualize(giff)
end