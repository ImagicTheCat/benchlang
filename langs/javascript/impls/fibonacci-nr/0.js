function fib(n) 
{
  if (n < 2) return n;
  return fib(n-2)+fib(n-1);
}

console.log(fib(parseInt(process.argv[2])));
