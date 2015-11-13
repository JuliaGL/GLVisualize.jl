using VideoIO

function play(f, img)
end
io = VideoIO.open("test.mp4")
f = VideoIO.openvideo(io)


img = read(f, Image)
while !eof(f)
    read!(f, img)
    #sleep(1/30)
end