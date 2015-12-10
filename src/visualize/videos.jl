#this is just a temporary solution... Video IO should be integrated via FileIO



#Base.read(gif::File{:gif}) = vread(VideoIO.openvideo(abspath(gif)))
#=
Base.read(mp4::File{format"MP4"}) = vread(VideoIO.openvideo(filename(mp4)))
function vread(video_stream::VideoIO.VideoReader)
    t0 			 = read(video_stream)
    cd, w, h 	 = size(t0)
    giff 		 = foldp(play, reinterpret(RGB{UFixed8}, t0, (w, h)), Signal(video_stream), TIMER_SIGNAL)
end
=#
