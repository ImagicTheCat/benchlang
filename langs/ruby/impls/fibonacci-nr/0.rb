def fib(n)
  return n if n < 2
  return fib(n-2)+fib(n-1)
end

puts fib(ARGV[0].to_i)
