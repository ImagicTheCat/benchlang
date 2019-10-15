#include <stdio.h>
#include <stdlib.h>

long fib(int n){
  if (n < 2)
    return n;
  else
    return fib(n-2)+fib(n-1);
}

int main(int argc, char **argv){
  printf("%d\n", fib(atoi(argv[1])));
}
