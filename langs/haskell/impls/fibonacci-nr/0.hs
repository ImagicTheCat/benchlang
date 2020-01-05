module Main where
import System.Environment

fib 0 = 1
fib 1 = 1
fib n = fib(n-1) + fib(n-2)

main = do
    args <- getArgs
    print(fib(read(args!!0)-1))
