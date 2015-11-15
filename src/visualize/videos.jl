#this is just a temporary solution... Video IO should be integrated via FileIO
export play

function play{T}(array::Array{T, 3}, slice)
    array[:, :, slice]
end

function play{T}(buffer::Array{T, 2}, video_stream, t)
    eof(video_stream) && seekstart(video_stream)
    w,h 	= size(buffer)
    buffer 	= reinterpret(UInt8, buffer, (3, w,h))
    read!(video_stream, buffer) # looses type and shape
    return reinterpret(T, buffer, (w,h))
end


#Base.read(gif::File{:gif}) = vread(VideoIO.openvideo(abspath(gif)))
#=
Base.read(mp4::File{format"MP4"}) = vread(VideoIO.openvideo(filename(mp4)))
function vread(video_stream::VideoIO.VideoReader)
    t0 			 = read(video_stream)
    cd, w, h 	 = size(t0)
    giff 		 = foldp(play, reinterpret(RGB{UFixed8}, t0, (w, h)), Signal(video_stream), TIMER_SIGNAL)
end
=#
