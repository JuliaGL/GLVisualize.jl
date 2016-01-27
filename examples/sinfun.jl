function matgen(n)
  tmp = 1.0 / n / n
  [ tmp * (i - j) * (i + j - 2) for i=1:n, j=1:n ]
end

function mul_line(n, linea, lineb)
  s = 0.0
  for i=1:n
    s += linea[i] * lineb[i]
  end
  s
end

function mul(a, b)
  m = size(a)[1]
  n = size(a)[2]
  p = size(b)[2]

  b2 = [ b[j, i] for i=1:p, j=1:n ]
  [ mul_line(n, a[i,:], b2[j,:]) for i=1:m, j=1:p ]
end

function main()
  n = 100
  if length(ARGS) >= 1
    n = int(ARGS[1])
  end
  t = time()
  n = div(n, 2) * 2
  a = matgen(n)
  b = matgen(n)
  c = mul(a, b)
  v = div(n,2) + 1
  println(c[v, v])
  println(time() - t)
end

main()
# 5.88 ms [5.46 ms, 6.30 ms]
#18.01 mb
# 1.48 ms [1.30 ms, 1.65 ms]
# 1.83 mb
