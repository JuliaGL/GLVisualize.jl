function create_docs(name)
    source_code = readall(open(Pkg.dir("GLVisualize", "examples", name)))
    path = videopath(name)
    """
    <h1>$(ucfirst(name))</h1>
    <video  width="480" height="300" autoplay loop>
      <source src="$path">
          Your browser does not support the video tag.
    </video>

    {% highlight julia %}
    $(source_code)
    {% endhighlight %}
    """
end