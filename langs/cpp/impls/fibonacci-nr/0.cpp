#include <iostream>
#include <sstream>

long fib(int n){
  if (n < 2)
    return n;
  else
    return fib(n-2)+fib(n-1);
}

int main(int argc, char **argv){
  std::stringstream ss(argv[1]);
  int n;
  ss >> n;

  std::cout << fib(n) << std::endl;;
}
