use std::io;
use std::time::Instant;

fn fib(n: u64) -> u64 {
    if n < 2 {
        n
    } else {
        fib(n - 1) + fib(n - 2)
    }
}

fn main() {
    println!("Number: ");

    let mut input = String::new();
    io::stdin().read_line(&mut input).expect("Failed to read line");

    let n: u64 = input.trim().parse().expect("Please enter a valid number");

    let t0 = Instant::now();
    let ans = fib(n);
    let t1 = Instant::now();

    let duration = t1.duration_since(t0);

    println!("Computed fib({}) = {} in {:.6} seconds.", n, ans, duration.as_secs_f64());
}


