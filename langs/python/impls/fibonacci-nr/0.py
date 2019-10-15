import sys

def fib(n):
    if n < 2:
        return n
    else:
        return fib(n-2)+fib(n-1)

def main():
    n = int(sys.argv[1])
    print(fib(n))
main()
