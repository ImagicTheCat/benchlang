module Main where
import System.Environment

fib = 1 : 1 : zipWith (+) fib (tail fib)

main = do
    args <- getArgs
    print (fib !! (read(args!!0)-1))
