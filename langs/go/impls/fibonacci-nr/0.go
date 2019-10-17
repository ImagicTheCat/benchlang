package main
import(
 "fmt"
 "os"
 "strconv"
)

func fib(n int) int {
  if n < 2 {
   return n
  }
  return fib(n-2)+fib(n-1)
}

func main() {
  n, err := strconv.Atoi(os.Args[1])
  if(err == nil){
    fmt.Println(fib(n))
  }
}
