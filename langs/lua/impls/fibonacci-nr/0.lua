local function fib(n)
  if n < 2 then
    return n
  else
    return fib(n-2)+fib(n-1)
  end
end

local n = ...
print(fib(tonumber(n)))
