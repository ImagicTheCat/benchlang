using System;

class App 
{
  public static int fib(int n) 
  {
    return (n < 2) ? n : fib(n-2)+fib(n-1);
  }

  public static int Main(String[] args) 
  {
    int n = System.Convert.ToInt32(args[0]);
    Console.WriteLine(fib(n).ToString());
    return(0);
  }
}
