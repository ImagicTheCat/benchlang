function fib(n)
  if n < 2
    return n
  else
    return fib(n-2)+fib(n-1)
  end
end

println(fib(parse(Int, ARGS[1])))
