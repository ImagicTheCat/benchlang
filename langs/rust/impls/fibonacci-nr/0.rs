use std::env;

fn fib(n: i32) -> i32 {
    if n < 2 {
        return n;
    }
    return fib(n - 2) + fib(n - 1);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let n: i32 = match args[1].parse(){
        Ok(n) => { n },
        Err(_) => { return; }
    };
    println!("{}", fib(n));
}
