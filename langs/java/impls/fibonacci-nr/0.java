// !BENCHLANG::(CLASS)=[Fib]

public class Fib
{
  public static void main(String args[]) 
  {
    int n = Integer.parseInt(args[0]);
    System.out.println(fib(n));
  }

  public static int fib(int n) 
  {
    if(n < 2) return(n);
    return fib(n-2)+fib(n-1);
  }
}
