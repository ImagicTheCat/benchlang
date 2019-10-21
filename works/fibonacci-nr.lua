return {
  version = 1,
  title = "Fibonacci (naive recursion)",
  description = [[
The goal is to measure performance of a recursive function pattern like Fibonacci.
It should be implemented as close as possible to the following mathematical function.

A000045 OEIS
Fibonacci numbers: F(n) = F(n-1) + F(n-2) with F(0) = 0 and F(1) = 1.

args: n
output: f(n) number as text
  ]],
  steps = { -- list of {params...}
    {"7"},
    {"25"},
    {"40"}
  },
  check = function(output, n)
    local fn = tonumber(output)
    if n == "7" then
      return fn == 13
    elseif n == "25" then
      return fn == 75025
    elseif n == "40" then
      return fn == 102334155
    end
  end
}
