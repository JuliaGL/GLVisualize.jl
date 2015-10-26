using ZipFile
tmp = download("http://staging.enthought.com/projects/mayavi/N36W113.hgt.zip")
zr = Reader(tmp)
println(zr)